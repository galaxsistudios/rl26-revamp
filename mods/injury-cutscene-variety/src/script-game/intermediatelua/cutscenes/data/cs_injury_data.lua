local var_0_0 = native.ECutsceneOrigin.PrimaryActor
local var_0_1 = native.ECutsceneOrigin.PrimaryActorFacingOrigin
local var_0_2 = native.ECutsceneOrigin.CenterAroundActors
local var_0_3 = native.ECutsceneOrigin.World
local var_0_4 = native.ECutsceneOrigin.Custom

default_near = 0.5
default_far = 1200
CutsceneData = {
	InjuryAnkle_01 = {
		povCameraAllowed = false,
		animsetName = "cutsceneInjuries",
		hideBall = true,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_injury_ankle_01",
				name = "player",
				optional = false,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_injury_ankle_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_ankle_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_ankle_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera03",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
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
		}
	},
	InjuryArm_01 = {
		animsetName = "cutsceneInjuries",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_injury_arm_01",
				name = "player",
				optional = false,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_injury_arm_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_arm_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0.7,
						nearIntensity = 0.2,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.6,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_arm_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player",
				safe = true,
				jointName = "cs_camera03",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 2,
						targetActor = "player",
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
		}
	},
	InjuryBack_01 = {
		povCameraAllowed = false,
		animsetName = "cutsceneInjuries",
		hideBall = true,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_injury_back_01",
				name = "player",
				optional = false,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_injury_back_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_back_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_back_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera03",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
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
		}
	},
	InjuryHead_01 = {
		animsetName = "cutsceneInjuries",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_injury_head_01",
				name = "player",
				optional = false,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_injury_head_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_head_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0.7,
						nearIntensity = 0.2,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.6,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_head_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera03",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 2,
						targetActor = "player",
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
		}
	},
	InjuryKnee_01 = {
		animsetName = "cutsceneInjuries",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_injury_knee_01",
				name = "player",
				optional = false,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_injury_knee_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_knee_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0.7,
						nearIntensity = 0.2,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.6,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_knee_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera03",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.25,
						focusDistance = "auto",
						frame = 0,
						aperture = 0.8,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					},
					{
						intensity = 0.5,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 75,
						aperture = 1.6,
						targetActor = "player",
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
		}
	},
	InjuryTorso_01 = {
		povCameraAllowed = false,
		animsetName = "cutsceneInjuries",
		hideBall = true,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "p1_rl1_injury_torso_01",
				name = "player",
				optional = false,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "p1_rl1_injury_torso_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.2,
						focusDistance = "auto",
						frame = 0,
						aperture = 3,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_torso_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.2,
						focusDistance = "auto",
						frame = 0,
						aperture = 3,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "p1_rl1_injury_torso_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player",
				jointName = "cs_camera03",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.2,
						focusDistance = "auto",
						frame = 0,
						aperture = 3,
						targetActor = "player",
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
		}
	},
	-- injury-cutscene-variety: RL26 ships these clips (cutsceneInjuries) but never plays them;
	-- definitions modelled on Rugby 25's InjuryConcussion_01 / InjuryHamstring_01.,
	InjuryConcussion_01 = {
		animsetName = "cutsceneInjuries",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "injury_concussion_01",
				name = "player",
				optional = false,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "injury_concussion_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "injury_concussion_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0.7,
						nearIntensity = 0.2,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.6,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
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
	},
	InjuryHamstring_01 = {
		animsetName = "cutsceneInjuries",
		povCameraAllowed = false,
		cutsceneOrigin = var_0_0,
		actors = {
			{
				animName = "injury_hamstring_01",
				name = "player",
				optional = false,
				filter = {
					actorType = "player"
				}
			}
		},
		cameras = {
			{
				animName = "injury_hamstring_01",
				name = "cs_camera01",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera01",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0.5,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.2,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "injury_hamstring_01",
				name = "cs_camera02",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera02",
				dof = {
					{
						intensity = 0.7,
						nearIntensity = 0.2,
						focusDistance = "auto",
						frame = 0,
						aperture = 2.6,
						targetActor = "player",
						autoDofJoints = {
							"hips"
						}
					}
				}
			},
			{
				animName = "injury_hamstring_01",
				name = "cs_camera03",
				moveRelativeToActorLabel = "player",
				near = 0.1,
				jointName = "cs_camera03",
				dof = {
					{
						intensity = 0.5,
						nearIntensity = 0,
						focusDistance = "auto",
						frame = 0,
						aperture = 2,
						targetActor = "player",
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
		}
	}
}
