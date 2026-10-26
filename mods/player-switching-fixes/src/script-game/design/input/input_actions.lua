import("design.input.default_input_actions")
import("design.input.default_input_actions_switch")
import("core.foundation.tablex")
import("script-config.design.passing_config")
import("script-config.design.player_config")
import("design.playtheball_config")
import("ai.try.try_config")

local var_0_0 = player_config.controlGracePeriod
local var_0_1 = player_config.fastControlGracePeriod

ActionProperties = {
	Global = {
		ExtraEffort = {
			trigger = "down"
		},
		FineTuneX = {},
		FineTuneY = {},
		ForceStrafe = {
			trigger = "down"
		},
		MovePlayer = {
			trigger = "down"
		},
		MovePlayerX = {},
		MovePlayerY = {},
		RadialSelectControlledPlayer = {
			trigger = "press"
		},
		RightStickX = {},
		RightStickY = {},
		Sprint = {
			trigger = "hold"
		},
		Strafe = {
			trigger = "hold"
		},
		SwitchRuleStates = {
			trigger = "press"
		}
	},
	Training = {
		Option1 = {
			trigger = "press"
		},
		Option2 = {
			trigger = "press"
		},
		Option3 = {
			trigger = "press"
		},
		Option4 = {
			trigger = "press"
		}
	},
	DeadBall = {
		Skip1 = {
			trigger = "press"
		},
		Skip2 = {
			trigger = "press"
		},
		Skip3 = {
			trigger = "press"
		},
		Skip4 = {
			trigger = "press"
		}
	},
	SkipCutscene = {
		Skip1 = {
			trigger = "release"
		}
	},
	SkipHighlightReel = {
		Skip1 = {
			trigger = "release"
		}
	},
	ExitManuallyLaunchedRulestate = {
		Skip1 = {
			trigger = "press"
		}
	},
	HaveBall = {
		CutoutFirstPassTarget = {
			trigger = "press"
		},
		CutoutFourthPassTarget = {
			trigger = "press"
		},
		CutoutPassPendingLeft = {
			trigger = "hold",
			timeout = var_0_0
		},
		CutoutPassPendingRight = {
			trigger = "hold",
			timeout = var_0_0
		},
		CutoutSecondPassTarget = {
			trigger = "press"
		},
		CutoutThirdPassTarget = {
			trigger = "press"
		},
		Fend = {
			trigger = "down"
		},
		FendOrSidestep = {
			trigger = "down"
		},
		HitUp = {
			trigger = "press"
		},
		HitUpHeld = {
			trigger = "down"
		},
		PassLeft = {
			trigger = "press",
			timeout = passing_config.executeCutoutPassTime
		},
		PassLeftDownDuringTackle = {
			trigger = "down"
		},
		PassLeftDuringTackle = {
			trigger = "press"
		},
		PassLeftHeld = {
			trigger = "down"
		},
		PassLeftHeldDuringTackle = {
			trigger = "hold"
		},
		PassRight = {
			trigger = "press",
			timeout = passing_config.executeCutoutPassTime
		},
		PassRightDownDuringTackle = {
			trigger = "down"
		},
		PassRightDuringTackle = {
			trigger = "press"
		},
		PassRightHeld = {
			trigger = "down"
		},
		PassRightHeldDuringTackle = {
			trigger = "hold"
		},
		Taunt = {
			trigger = "press"
		}
	},
	DontHaveBall = {
		BallStrip = {
			trigger = "hold"
		},
		BigHit = {
			trigger = "hold"
		},
		ChargeDown = {
			trigger = "down"
		},
		-- player-switching-fixes: was "release", which was lost when the press lasted
		-- past the 0.2 s hold window of the stick-switching action on the same button
		ClassicSwitchLeft = {
			trigger = "press"
		},
		-- player-switching-fixes: was "release", which was lost when the press lasted
		-- past the 0.2 s hold window of the stick-switching action on the same button
		ClassicSwitchRight = {
			trigger = "press"
		},
		SwitchFullBackLeft = {
			trigger = "release",
			timeout = var_0_1
		},
		SwitchFullBackRight = {
			trigger = "release",
			timeout = var_0_1
		},
		ControlledMovement = {
			trigger = "hold",
			timeout = var_0_0
		},
		-- player-switching-fixes: was "release", which was lost when the press lasted
		-- past the 0.2 s hold window of the stick-switching action on the same button
		CycleBest = {
			trigger = "press"
		},
		DiveOnBall = {
			trigger = "down"
		},
		DivingTackle = {
			trigger = "press"
		},
		HighTackle = {
			trigger = "hold"
		},
		HoldTryLineTackle1 = {
			trigger = "press"
		},
		HoldTryLineTackle2 = {
			trigger = "press"
		},
		HoldTryLineTackle3 = {
			trigger = "press"
		},
		HoldTryLineTackle4 = {
			trigger = "press"
		},
		InterceptPass = {
			trigger = "hold"
		},
		LeaveBall = {
			trigger = "down"
		},
		LowTackle = {
			trigger = "hold"
		},
		ManualCollectBall = {
			trigger = "down"
		},
		PassToMe = {
			trigger = "release"
		},
		PassToMeBreakPlay = {
			trigger = "press"
		},
		PlayerSwitchDirection = {
			trigger = "down"
		},
		PlayerSwitchDirectionPress = {
			trigger = "down"
		},
		SoccerKick = {
			trigger = "down"
		},
		StickSwitching1 = {
			trigger = "hold",
			timeout = var_0_0
		},
		StickSwitching2 = {
			trigger = "hold",
			timeout = var_0_0
		},
		-- player-switching-fixes: was "release", which was lost when the press lasted
		-- past the 0.2 s hold window of the stick-switching action on the same button
		SwitchToBest = {
			trigger = "press"
		},
		TacklePushDirection = {
			trigger = "down"
		},
		ToeKick = {
			trigger = "down"
		}
	},
	Contest = {
		Tap = {
			trigger = "press"
		},
		TapDirection = {
			trigger = "down"
		},
		Collect = {
			trigger = "press"
		},
		CollectDropDown = {
			trigger = "press"
		}
	},
	Kicking = {
		KickPlayBomb = {
			trigger = "down"
		},
		KickPlayChipOrFieldGoal = {
			trigger = "press"
		},
		KickPlayChipOrFieldGoalHeld = {
			trigger = "down"
		},
		KickPlayGrubber = {
			trigger = "down"
		},
		KickPlayPunt = {
			trigger = "down"
		},
		TargetKickModifier = {
			trigger = "hold"
		}
	},
	Tackle = {
		PushTackle = {
			trigger = "down"
		},
		DiveTackle = {
			trigger = "down"
		},
		TryInTackle = {
			trigger = "press"
		},
		BallStrip = {
			trigger = "hold"
		},
		BigHit = {
			trigger = "down"
		},
		HoldTackle = {
			trigger = "down"
		}
	},
	PlayTheBall = {
		HoldDownTackle = {
			trigger = "hold"
		},
		HoldDownTackleArmPin = {
			trigger = "hold"
		},
		HoldDownTackleLow = {
			trigger = "hold"
		},
		HoldDownTackleDive = {
			trigger = "hold"
		},
		HoldDownTackleStick = {
			trigger = "down"
		},
		StruggleHold = {
			trigger = "hold"
		},
		StruggleRelease = {
			trigger = "release"
		},
		StrugglePress = {
			trigger = "press"
		},
		getTackled = {
			trigger = "press"
		},
		debugStates = {
			trigger = "press"
		},
		debugMeterStates = {
			trigger = "press"
		},
		userAccept = {
			trigger = "press"
		},
		debugSetZones = {
			trigger = "release"
		},
		debugResetZone = {
			trigger = "release"
		},
		StruggleStick = {
			trigger = "down"
		},
		ScootX = {},
		ScootY = {},
		LeftPlaySelect = {
			trigger = "press"
		},
		RightPlaySelect = {
			trigger = "press"
		},
		QuickPlayTheBall = {
			trigger = "doubleTap",
			timeout = playtheball_config.doubleTapWindow
		},
		-- faster-play-the-ball (lives here because build.py allows one owner per
		-- file): attacking quick play-the-ball, double-tap right trigger
		QuickPlayTheBallAttack = {
			trigger = "doubleTap",
			timeout = playtheball_config.doubleTapWindow
		}
	},
	DummyHalf = {
		Scoot = {
			trigger = "down"
		},
		SetPocketPlay = {
			trigger = "press"
		}
	},
	PlayerStrengths = {
		Activate = {
			trigger = "press"
		},
		Select = {
			trigger = "press"
		},
		Cancel = {
			trigger = "press"
		},
		MoveUp = {
			trigger = "press"
		},
		MoveDown = {
			trigger = "press"
		},
		MoveLeft = {
			trigger = "press"
		},
		MoveRight = {
			trigger = "press"
		}
	},
	ControlsHelp = {
		Activate = {
			trigger = "press"
		},
		Select = {
			trigger = "press"
		},
		Cancel = {
			trigger = "press"
		},
		MoveLeft = {
			trigger = "press"
		},
		MoveRight = {
			trigger = "press"
		}
	},
	Scorecard = {
		Activate = {
			trigger = "press"
		},
		MoveLeft = {
			trigger = "press"
		},
		MoveRight = {
			trigger = "press"
		},
		Cancel = {
			trigger = "press"
		}
	},
	AntVision = {
		Skip = {
			trigger = "press"
		}
	},
	Drills = {
		Back = {
			trigger = "press"
		},
		Continue = {
			trigger = "press"
		},
		ContinueResults = {
			trigger = "press"
		},
		Down = {
			trigger = "press"
		},
		Leaderboard = {
			trigger = "press"
		},
		LeaderboardDown = {
			trigger = "down"
		},
		LeaderboardUp = {
			trigger = "down"
		},
		Left = {
			trigger = "press"
		},
		NextLeaderboardFilter = {
			trigger = "release"
		},
		PreviousLeaderboardFilter = {
			trigger = "release"
		},
		Reset = {
			trigger = "release"
		},
		Retry = {
			trigger = "press"
		},
		Right = {
			trigger = "press"
		},
		ShowGamerCard = {
			trigger = "release"
		},
		ToggleTutorials = {
			trigger = "press"
		},
		Up = {
			trigger = "press"
		}
	},
	PassingDrill = {
		DecreaseDifficulty = {
			trigger = "release"
		},
		Down = {
			trigger = "release"
		},
		IncreaseDifficulty = {
			trigger = "release"
		},
		Instructions = {
			trigger = "release"
		},
		Left = {
			trigger = "release"
		},
		Reset = {
			trigger = "release"
		},
		ResetBags = {
			trigger = "release"
		},
		Retry = {
			trigger = "release"
		},
		Right = {
			trigger = "release"
		},
		Up = {
			trigger = "release"
		}
	},
	Debug = {
		DisableTackle = {
			trigger = "press"
		}
	},
	Try = {
		TryAttempt = {
			trigger = "press"
		},
		DiveTryAttempt = {
			trigger = "doubleTap",
			timeout = try_config.DoubleTapWindow
		},
		TryAttemptInTackle = {
			trigger = "down"
		},
		TryAttemptExtra1 = {
			trigger = "release"
		},
		TryAttemptExtra2 = {
			trigger = "release"
		},
		TryAttemptExtra3 = {
			trigger = "release"
		},
		TryAttemptDiveExtra1 = {
			trigger = "press"
		},
		TryAttemptDiveExtra2 = {
			trigger = "press"
		},
		TryAttemptDiveExtra3 = {
			trigger = "press"
		},
		TryAttemptHeldExtra1 = {
			trigger = "down"
		},
		TryAttemptHeldExtra2 = {
			trigger = "down"
		},
		TryAttemptHeldExtra3 = {
			trigger = "down"
		}
	},
	PenaltySelect = {
		TapRestart = {
			trigger = "press"
		},
		KickToTouch = {
			trigger = "press"
		},
		PenaltyGoalAttempt = {
			trigger = "press"
		}
	},
	PlaceKick = {
		TargetX = {},
		TargetY = {},
		InitiateKick = {},
		PowerX = {},
		PowerY = {},
		Swing = {},
		AcceptBallPosition = {
			trigger = "release"
		},
		SkipPlaceBall = {
			trigger = "release"
		}
	},
	TeamOrders = {
		PassToMe = {
			trigger = "press"
		}
	},
	AttributeTestBed = {
		Reset1 = {
			trigger = "press"
		},
		Reset2 = {
			trigger = "press"
		},
		Clear1 = {
			trigger = "press"
		},
		Clear2 = {
			trigger = "press"
		},
		DifficultyDown = {
			trigger = "press"
		},
		DifficultyUp = {
			trigger = "press"
		}
	},
	ChargeDownTestBed = {
		Reset1 = {
			trigger = "hold"
		},
		Reset2 = {
			trigger = "hold"
		}
	},
	Tactics = {
		Up = {
			trigger = "press"
		},
		Down = {
			trigger = "press"
		},
		Left = {
			trigger = "press"
		},
		Right = {
			trigger = "press"
		}
	},
	BeAPro = {
		SkipToProPlayer = {
			trigger = "press"
		},
		BackToProPlayer = {
			trigger = "press"
		}
	},
	KonamiCode = {
		Up = {
			trigger = "press"
		},
		Down = {
			trigger = "press"
		},
		Left = {
			trigger = "press"
		},
		Right = {
			trigger = "press"
		},
		B = {
			trigger = "press"
		},
		A = {
			trigger = "press"
		},
		X = {
			trigger = "press"
		},
		Y = {
			trigger = "press"
		}
	},
	Substitutions = {
		Back = {
			trigger = "press"
		},
		Up = {
			trigger = "press"
		},
		Down = {
			trigger = "press"
		},
		Left = {
			trigger = "press"
		},
		Right = {
			trigger = "press"
		}
	},
	Stroke = {
		Target = {
			trigger = "down"
		},
		TargetX = {},
		TargetY = {}
	},
	Serve = {
		FlatServe = {
			trigger = "press",
			timeout = var_0_0
		},
		FlatServeHeld = {
			trigger = "release"
		},
		TopSpinServe = {
			trigger = "press",
			timeout = var_0_0
		},
		TopSpinServeHeld = {
			trigger = "release"
		},
		SliceServe = {
			trigger = "press",
			timeout = var_0_0
		},
		SliceServeHeld = {
			trigger = "release"
		}
	},
	CaptainsChallenge = {
		CaptainsChallengeSelect = {
			trigger = "press"
		},
		CaptainsChallengeSkip = {
			trigger = "press"
		}
	}
}

local var_0_2 = default_input_actions.Actions

DefaultInputMaps = {
	Gamepad = var_0_2.Gamepad,
	Mouse = var_0_2.Mouse
}

if PLATFORM_SWITCH_ANY then
	for iter_0_0, iter_0_1 in pairs(var_0_2.Gamepad) do
		DefaultInputMaps.Gamepad[iter_0_0] = tablex.merge(DefaultInputMaps.Gamepad[iter_0_0], default_input_actions_switch.Gamepad[iter_0_0])
	end
end

if not IS_RETAIL or PLATFORM_PC then
	DefaultInputMaps.Keyboard = var_0_2.Keyboard
end

if not IS_RETAIL or PLATFORM_PS4 then
	DefaultInputMaps.Vita = var_0_2.Vita
end

if not IS_RETAIL or PLATFORM_SWITCH_ANY then
	DefaultInputMaps.Joycon_SingleLeft = var_0_2.Joycon_SingleLeft
	DefaultInputMaps.Joycon_SingleRight = var_0_2.Joycon_SingleRight
end

local var_0_3 = false

function initMaps()
	if not var_0_3 then
		native.NInputControllerFunctions.initActionProperties(ActionProperties)
		native.NInputControllerFunctions.initDefaultInputMaps(DefaultInputMaps)

		var_0_3 = true
	end
end

initMaps()
