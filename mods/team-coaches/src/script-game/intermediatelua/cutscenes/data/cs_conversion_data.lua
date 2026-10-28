local var_0_0 = native.ECutsceneOrigin.PrimaryActor
local var_0_1 = native.ECutsceneOrigin.PrimaryActorFacingOrigin
local var_0_2 = native.ECutsceneOrigin.CenterAroundActors
local var_0_3 = native.ECutsceneOrigin.World
local var_0_4 = native.ECutsceneOrigin.Custom

default_near = 0.5
default_far = 1200
CutsceneData = {
	rl1_conversion_positive_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_conversion_positive",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		actors = {
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_positive_02 = {
		povCameraAllowed = false,
		animsetName = "rl1_conversion_positive",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		actors = {
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_positive_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
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
					camera = "cs_camera08"
				}
			}
		}
	},
	rl1_conversion_very_positive_01 = {
		animsetName = "rl1_conversion_positive",
		povCameraAllowed = false,
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_very_positive_02 = {
		animsetName = "rl1_conversion_positive",
		povCameraAllowed = false,
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera03",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_very_positive_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_negative_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_conversion_negative_01",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		actors = {
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_negative_02 = {
		povCameraAllowed = false,
		animsetName = "rl1_conversion_negative_02",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		actors = {
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_negative_03 = {
		povCameraAllowed = false,
		animsetName = "rl1_conversion_negative_03",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		actors = {
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_negative_03",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_neutral_01 = {
		povCameraAllowed = false,
		animsetName = "rl1_conversion_neutral_01",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		actors = {
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_neutral_01_b = {
		povCameraAllowed = false,
		animsetName = "rl1_conversion_neutral_01_b",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		actors = {
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_01_b",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_neutral_02 = {
		povCameraAllowed = false,
		animsetName = "rl1_conversion_neutral_02",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		actors = {
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_neutral_03 = {
		animsetName = "rl1_conversion_neutral_03",
		povCameraAllowed = false,
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		actors = {
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_03",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_neutral_04 = {
		animsetName = "rl1_conversion_neutral_04",
		povCameraAllowed = false,
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		actors = {
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_04",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_neutral_05 = {
		animsetName = "rl1_conversion_neutral_05",
		povCameraAllowed = false,
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(1, 1),
		actors = {
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_neutral_05",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_l_01 = {
		checkCameraBoundary = true,
		animsetName = "rl1_conversion_l_01",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_conversion_l_01",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_l_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_l_02 = {
		checkCameraBoundary = true,
		animsetName = "rl1_conversion_l_02",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_conversion_l_02",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_l_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_02",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_l_03 = {
		checkCameraBoundary = true,
		animsetName = "rl1_conversion_l_03",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_conversion_l_03",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_l_03",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_03",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_03",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_03",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_03",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_03",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_03",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_03",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_l_04 = {
		checkCameraBoundary = true,
		animsetName = "rl1_conversion_l_04",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_conversion_l_04",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_l_04",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_04",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_04",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_04",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_04",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_04",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_04",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_04",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_l_05 = {
		checkCameraBoundary = true,
		animsetName = "rl1_conversion_l_05",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_conversion_l_05",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		props = {
			{
				propName = "props/kickingtee/models/conversionTee.model",
				attachTo = {
					jointName = "balljoint",
					name = "p1_cameraplayer"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_l_05",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_05",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_05",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_05",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_05",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_05",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_05",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_05",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_l_fail_01 = {
		checkCameraBoundary = true,
		animsetName = "rl1_conversion_l_fail_01",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_l_fail_02 = {
		checkCameraBoundary = true,
		animsetName = "rl1_conversion_l_fail_02",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_fail_02",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	},
	rl1_conversion_l_success_01 = {
		checkCameraBoundary = true,
		animsetName = "rl1_conversion_l_success_01",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "p1_cameraplayer",
				syncOnFrame = 1,
				optional = true,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera01",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera02",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.2,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "p1_cameraplayer",
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
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "cs_camera04",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera04",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "cs_camera05",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera05",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "cs_camera06",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera06",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "cs_camera07",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera07",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_conversion_l_success_01",
				name = "cs_camera08",
				moveRelativeToActorLabel = "p1_cameraplayer",
				near = 0.1,
				jointName = "cs_camera08",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {
					{
						intensity = 1.7,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "p1_cameraplayer",
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
			}
		}
	}
}

-- team-coaches: coach reaction cutscenes (played by CoachReactionRuleState).
-- Copies of the conversion-reaction close-ups with the actor slot retyped to
-- "npc" (the sideline coaches are pooled NPCObjects) and the kicking tee
-- removed. Origin stays PrimaryActor, so they play where the coach stands.
pcall(function()
	local rawtypeOf = rawtype or type
	local function copyData(value)
		if rawtypeOf(value) ~= "table" then
			return value
		end

		local result = {}

		for key, item in pairs(value) do
			result[key] = copyData(item)
		end

		return result
	end

	for name, source in pairs({
		teamcoaches_happy_01 = "rl1_conversion_very_positive_01",
		teamcoaches_happy_02 = "rl1_conversion_very_positive_02",
		teamcoaches_happy_03 = "rl1_conversion_positive_02",
		teamcoaches_gutted_01 = "rl1_conversion_negative_01",
		teamcoaches_gutted_02 = "rl1_conversion_negative_02",
		teamcoaches_gutted_03 = "rl1_conversion_negative_03"
	}) do
		local base = CutsceneData[source]

		if base and not CutsceneData[name] then
			local data = copyData(base)

			data.props = nil

			for _, actor in ipairs(data.actors or {}) do
				actor.filter = {
					actorType = "npc"
				}
			end

			CutsceneData[name] = data
		end
	end
end)
