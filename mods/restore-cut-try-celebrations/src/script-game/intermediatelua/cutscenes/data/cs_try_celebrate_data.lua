local var_0_0 = native.ECutsceneOrigin.PrimaryActor
local var_0_1 = native.ECutsceneOrigin.PrimaryActorFacingOrigin
local var_0_2 = native.ECutsceneOrigin.CenterAroundActors
local var_0_3 = native.ECutsceneOrigin.World
local var_0_4 = native.ECutsceneOrigin.Custom

default_near = 0.5
default_far = 1200
CutsceneData = {
	rl1_cs_trycelebrate_template = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_template_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "primary",
				syncOnFrame = 80,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_template",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_template",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_template",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p5_rl1_cs_trycelebrate_template",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p6_rl1_cs_trycelebrate_template",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_template",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_template",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
			},
			{
				{
					frame = 0,
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera09"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera10"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_fist_pump_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_fist_pump_01",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "primary",
				syncOnFrame = 80,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_fist_pump_01",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_fist_pump_01",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fist_pump_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_5
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_ball_kick_stands_03 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_ball_kick_stands_03",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "primary",
				syncOnFrame = 130,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_ball_kick_stands_03",
				optional = true,
				syncOnFrame = 130,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_ball_kick_stands_03",
				optional = true,
				syncOnFrame = 160,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		props = {
			{
				name = "ball",
				attachTo = {
					jointName = "balljoint",
					name = "primary"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ball_kick_stands_03",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_4
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_ground_getup_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_ground_getup_01",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "primary",
				syncOnFrame = 80,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_ground_getup_01",
				optional = true,
				syncOnFrame = 25,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_ground_getup_01",
				optional = true,
				syncOnFrame = 70,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_ground_getup_01",
				optional = true,
				syncOnFrame = 190,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p5_rl1_cs_trycelebrate_ground_getup_01",
				optional = true,
				syncOnFrame = 145,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p6_rl1_cs_trycelebrate_ground_getup_01",
				optional = true,
				syncOnFrame = 92,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_ground_getup_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_5
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_mid_slide_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_mid_slide_01",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "primary",
				syncOnFrame = 34,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_mid_slide_01",
				optional = true,
				syncOnFrame = 34,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_mid_slide_01",
				optional = true,
				syncOnFrame = 115,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_mid_slide_01",
				optional = true,
				syncOnFrame = 90,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_mid_slide_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_group_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_group_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "primary",
				syncOnFrame = 77,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_group_01",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_group_01",
				optional = true,
				syncOnFrame = 90,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_group_01",
				optional = true,
				syncOnFrame = 100,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p5_rl1_cs_trycelebrate_group_01",
				optional = true,
				syncOnFrame = 72,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p6_rl1_cs_trycelebrate_group_01",
				optional = true,
				syncOnFrame = 90,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_group_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_group_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_5
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_high_five_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_high_five_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "primary",
				syncOnFrame = 35,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_high_five_01",
				optional = true,
				syncOnFrame = 40,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_high_five_01",
				optional = true,
				syncOnFrame = 132,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_high_five_01",
				optional = true,
				syncOnFrame = 175,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p5_rl1_cs_trycelebrate_high_five_01",
				optional = true,
				syncOnFrame = 180,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_high_five_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_5
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_team_mate_grab_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_team_mate_grab_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "primary",
				syncOnFrame = 10,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_team_mate_grab_01",
				optional = true,
				syncOnFrame = 10,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_team_mate_grab_01",
				optional = true,
				syncOnFrame = 95,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_team_mate_grab_01",
				optional = true,
				syncOnFrame = 95,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_team_mate_grab_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_4
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_camera_interact_02 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_camera_interact_02_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "primary",
				syncOnFrame = 7,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_camera_interact_02",
				optional = true,
				syncOnFrame = 140,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_camera_interact_02",
				optional = true,
				syncOnFrame = 150,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_02",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_5
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera10"
				}
			}
		}
	},
	rl1_cs_trycelebrate_camera_interact_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_camera_interact_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "primary",
				syncOnFrame = 15,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_camera_interact_01",
				optional = true,
				syncOnFrame = 75,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_camera_interact_01",
				optional = true,
				syncOnFrame = 82,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera10"
				}
			}
		}
	},
	rl1_cs_trycelebrate_camera_interact_03 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_camera_interact_03_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "primary",
				syncOnFrame = 80,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_camera_interact_03",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_camera_interact_03",
				optional = true,
				syncOnFrame = 90,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_03",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera10"
				}
			}
		}
	},
	rl1_cs_trycelebrate_camera_interact_07 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_camera_interact_07_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "primary",
				syncOnFrame = 120,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_camera_interact_07",
				optional = true,
				syncOnFrame = 120,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_camera_interact_07",
				optional = true,
				syncOnFrame = 120,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_07",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_camera_interact_09 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_camera_interact_09_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_09",
				name = "primary",
				syncOnFrame = 120,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_camera_interact_09",
				optional = true,
				syncOnFrame = 120,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_camera_interact_09",
				optional = true,
				syncOnFrame = 120,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_09",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_09",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_09",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_09",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_09",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_09",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_camera_interact_09",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera10"
				}
			}
		}
	},
	rl1_cs_trycelebrate_back_pat_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_back_pat_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "primary",
				syncOnFrame = 35,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_back_pat_01",
				optional = true,
				syncOnFrame = 40,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_back_pat_01",
				optional = true,
				syncOnFrame = 132,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_back_pat_01",
				optional = true,
				syncOnFrame = 175,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 50,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 126,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 156,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.4,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 200,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 233,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 6,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 16,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 50,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 100,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 125,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 80,
						aperture = 6,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.3,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 95,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 110,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 35,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 142,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.3,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 166,
						aperture = 4.5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 190,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.8,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 49,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 124,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 150,
						aperture = 4.5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 0.9,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 190,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 45,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.25,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 120,
						aperture = 4.1,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 240,
						aperture = 4.3,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = "auto",
						frame = 78,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 0.5,
						nearIntensity = 1.5,
						focusDistance = "auto",
						frame = 140,
						aperture = 3,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 1,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.8,
						nearIntensity = 0.4,
						focusDistance = "auto",
						frame = 85,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 120,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 0.7,
						focusDistance = "auto",
						frame = 154,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_pat_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 0.7,
						focusDistance = "auto",
						frame = 85,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 0.6,
						focusDistance = "auto",
						frame = 110,
						aperture = 2.5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 0.7,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 145,
						aperture = 3.5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_2
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_power_pose_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_power_pose_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "primary",
				syncOnFrame = 35,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_power_pose_01",
				optional = true,
				syncOnFrame = 40,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_power_pose_01",
				optional = true,
				syncOnFrame = 132,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_power_pose_01",
				optional = true,
				syncOnFrame = 175,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 50,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 126,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 156,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.4,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 200,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 233,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 6,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 16,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 50,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 100,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 125,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 80,
						aperture = 6,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.3,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 95,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 110,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 35,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 142,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.3,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 166,
						aperture = 4.5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 190,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.8,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 49,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 124,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 150,
						aperture = 4.5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 0.9,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 190,
						aperture = 5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 45,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.25,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 120,
						aperture = 4.1,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 240,
						aperture = 4.3,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 1.5,
						focusDistance = "auto",
						frame = 78,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 0.5,
						nearIntensity = 1.5,
						focusDistance = "auto",
						frame = 140,
						aperture = 3,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 1,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.8,
						nearIntensity = 0.4,
						focusDistance = "auto",
						frame = 85,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 120,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1.2,
						nearIntensity = 0.7,
						focusDistance = "auto",
						frame = 154,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 0.7,
						focusDistance = "auto",
						frame = 85,
						aperture = 2,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 1,
						nearIntensity = 0.6,
						focusDistance = "auto",
						frame = 110,
						aperture = 2.5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 0.7,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 145,
						aperture = 3.5,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_power_pose_01",
				name = "cs_camera13",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera13",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 1,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_5
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera13"
				}
			}
		}
	},
	rl1_cs_trycelebrate_back_jump_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_back_jump_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "primary",
				syncOnFrame = 92,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_back_jump_01",
				optional = true,
				syncOnFrame = 44,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_back_jump_01",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_back_jump_01",
				optional = true,
				syncOnFrame = 95,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_back_jump_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_low_high_five_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_low_high_five_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "primary",
				syncOnFrame = 75,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_low_high_five_01",
				optional = true,
				syncOnFrame = 75,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_low_high_five_01",
				optional = true,
				syncOnFrame = 90,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_1
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_low_high_five_02 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_low_high_five_02_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "primary",
				syncOnFrame = 79,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_low_high_five_02",
				optional = true,
				syncOnFrame = 79,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_low_high_five_02",
				optional = true,
				syncOnFrame = 77,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_low_high_five_02",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_1
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "primary",
				syncOnFrame = 73,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_01",
				optional = true,
				syncOnFrame = 73,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_og_trycelebrate_hug_01",
				optional = true,
				syncOnFrame = 89,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_02 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_02_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "primary",
				syncOnFrame = 60,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_02",
				optional = true,
				syncOnFrame = 60,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_og_trycelebrate_hug_02",
				optional = true,
				syncOnFrame = 60,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_og_trycelebrate_hug_02",
				optional = true,
				syncOnFrame = 60,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_02",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_03 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_03_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "primary",
				syncOnFrame = 75,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_03",
				optional = true,
				syncOnFrame = 60,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_og_trycelebrate_hug_03",
				optional = true,
				syncOnFrame = 90,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_og_trycelebrate_hug_03",
				optional = true,
				syncOnFrame = 106,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_03",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_04 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_04_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "primary",
				syncOnFrame = 45,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_04",
				optional = true,
				syncOnFrame = 45,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_og_trycelebrate_hug_04",
				optional = true,
				syncOnFrame = 60,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_og_trycelebrate_hug_04",
				optional = true,
				syncOnFrame = 95,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_04",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_04",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_05 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_05_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "primary",
				syncOnFrame = 52,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_05",
				optional = true,
				syncOnFrame = 52,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_05",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_06 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_06_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "primary",
				syncOnFrame = 75,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_06",
				optional = true,
				syncOnFrame = 75,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_06",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_07 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_07_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "primary",
				syncOnFrame = 80,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_07",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_og_trycelebrate_hug_07",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_og_trycelebrate_hug_07",
				optional = true,
				syncOnFrame = 80,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_07",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_08 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_08_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "primary",
				syncOnFrame = 75,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_08",
				optional = true,
				syncOnFrame = 75,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_08",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_low5_hug_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_low5_hug_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "primary",
				syncOnFrame = 48,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_low5_hug_01",
				optional = true,
				syncOnFrame = 48,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_low5_hug_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_2
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_hug_runoff_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_hug_runoff_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "primary",
				syncOnFrame = 60,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_hug_runoff_01",
				optional = true,
				syncOnFrame = 60,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_hug_runoff_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_og_trycelebrate_scruffhair_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_og_trycelebrate_scruffhair_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "primary",
				syncOnFrame = 75,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_og_trycelebrate_scruffhair_01",
				optional = true,
				syncOnFrame = 75,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_og_trycelebrate_scruffhair_01",
				optional = true,
				syncOnFrame = 90,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_og_trycelebrate_scruffhair_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_wing_halfback_handshake_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_wing_halfback_handshake_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "primary",
				syncOnFrame = 30,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				optional = true,
				syncOnFrame = 30,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				optional = true,
				syncOnFrame = 60,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p4_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				optional = true,
				syncOnFrame = 30,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_wing_halfback_handshake_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_fwd_low_energy_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_cs_trycelebrate_fwd_low_energy_01_animset",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "primary",
				syncOnFrame = 40,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_rl1_cs_trycelebrate_fwd_low_energy_01",
				optional = true,
				syncOnFrame = 40,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_rl1_cs_trycelebrate_fwd_low_energy_01",
				optional = true,
				syncOnFrame = 40,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera09",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera09",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera10",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera10",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera11",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera11",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_cs_trycelebrate_fwd_low_energy_01",
				name = "cs_camera12",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera12",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.6,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
					camera = "cs_camera05"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera06"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera07"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera08"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera09"
				}
			},
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
					camera = "cs_camera11"
				}
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera12"
				}
			}
		}
	},
	rl1_cs_trycelebrate_mr_bow_arrow_01 = {
		povCameraAllowed = false,
		animsetName = "cutsceneTryCelebrateMrBowArrow01",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_cs_trycelebrate_mr_bow_arrow_01",
				name = "primary",
				syncOnFrame = 110,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_cs_trycelebrate_mr_bow_arrow_01",
				optional = true,
				syncOnFrame = 110,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p3_cs_trycelebrate_mr_bow_arrow_01",
				optional = true,
				syncOnFrame = 110,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_cs_trycelebrate_mr_bow_arrow_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_trycelebrate_mr_bow_arrow_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_trycelebrate_mr_bow_arrow_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				safe = true,
				name = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				jointName = "cs_camera04",
				animName = "p1_cs_trycelebrate_mr_bow_arrow_01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera04"
				}
			}
		}
	},
	cs_trycelebrate_tapshoulder_01 = {
		povCameraAllowed = false,
		animsetName = "cutsceneTryCelebrateTapshoulder01",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_cs_trycelebrate_tapshoulder_01",
				name = "primary",
				syncOnFrame = 75,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_cs_trycelebrate_tapshoulder_01",
				optional = true,
				syncOnFrame = 75,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_cs_trycelebrate_tapshoulder_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_trycelebrate_tapshoulder_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_trycelebrate_tapshoulder_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_trycelebrate_tapshoulder_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera04"
				}
			}
		}
	},
	cs_trycelebrate_scruffhair_02 = {
		povCameraAllowed = false,
		animsetName = "cutsceneTryCelebrateScruffleHair02",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_cs_trycelebrate_scruffhair_02",
				name = "primary",
				syncOnFrame = 75,
				optional = true,
				filter = {
					actorType = "player"
				}
			},
			{
				animName = "p2_cs_trycelebrate_scruffhair_02",
				optional = true,
				syncOnFrame = 75,
				syncTo = "primary",
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_cs_trycelebrate_scruffhair_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_trycelebrate_scruffhair_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_trycelebrate_scruffhair_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_trycelebrate_scruffhair_02",
				name = "cs_camera04",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera04"
				}
			}
		}
	},
	cs_tryneutral_tapchest_01 = {
		povCameraAllowed = false,
		animsetName = "cutsceneTryNeutralTapchest01",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_cs_tryneutral_tapchest_01",
				name = "primary",
				syncOnFrame = 75,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_cs_tryneutral_tapchest_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_tryneutral_tapchest_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_tryneutral_tapchest_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_cs_tryneutral_tapchest_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "primary",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
			},
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera04"
				}
			}
		}
	},
	rl1_try_jack_howarth_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "jack_howarth_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "jack_howarth_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_sua_faalogo_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "sua_faalogo_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "sua_faalogo_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_harry_grant_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "harry_grant_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "harry_grant_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_cameron_munster_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "cameron_munster_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "cameron_munster_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_jahrome_hughes_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "jahrome_hughes_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "jahrome_hughes_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_nick_meaney_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "nick_meaney_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "nick_meaney_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_josh_king_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "josh_king_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "josh_king_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_tyran_wishart_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "tyran_wishart_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "tyran_wishart_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_moses_leo_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "moses_leo_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "moses_leo_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_shawn_blore_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "shawn_blore_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "shawn_blore_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_will_warbrick_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "will_warbrick_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "will_warbrick_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_alec_macdonald_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "alec_macdonald_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "alec_macdonald_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_xavier_coates_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "xavier_coates_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "xavier_coates_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_joe_chan_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "joe_chan_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "joe_chan_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			}
		},
		cuts = {
			{
				{
					frame = 0,
					transition = "cut",
					camera = "cs_camera01"
				}
			}
		}
	},
	rl1_try_tui_kamikamica_celebration = {
		povCameraAllowed = false,
		animsetName = "cutsceneStormPromo",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "tui_kamikamica_celebration",
				name = "primary",
				syncOnFrame = 0,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "tui_kamikamica_celebration",
				name = "cs_camera01",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "tui_kamikamica_celebration",
				name = "cs_camera02",
				moveRelativeToActorLabel = "primary",
				motionPushInFovScale = 0.82,
				motionDollyDistance = 0.6,
				motionSway = 0.04,
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {
							"hips"
						}
					}
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
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			},
			{
				frame = 15,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 25,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 35,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 45,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 55,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 65,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 75,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 85,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
			},
			{
				frame = 95,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_01"
			},
			{
				frame = 105,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_02"
			},
			{
				frame = 115,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_03"
			},
			{
				frame = 125,
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_04"
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
			}
		}
	}
}
