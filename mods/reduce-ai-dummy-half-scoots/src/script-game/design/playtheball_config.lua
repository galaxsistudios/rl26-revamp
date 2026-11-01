import("core.foundation.cclass")

DisposalVelocityModifier = 1
IncapactionDuration = 4
offsetFromSideLine = 10
offsetFromTryLine = 10
checkInsideFieldOffset = 0.5
getInsideFieldOffset = 1
playTheBallInTouchImmuneWindow = 1
doubleTapWindow = 0.2
ScootStickDeadzone = 0.3
defensivePlayTheBallSpeed = "sprint_speed"

local var_0_0 = GAME_RUGBY

luaConfig = {
	dummyHalfOffset = -0.1,
	timeToRemainInPostPlayTheBall = 1.75,
	playTheBallCompleteTime = 1.6,
	pairedMarkerOneOffset = 2,
	-- faster-play-the-ball (lives here: one owner per file): stock 2.5. Caps the heel-back speed so the ball
	-- stops at the dummy half's feet instead of rolling past him.
	maxBallDisposalSpeed = 1.8,
	postPlayTheBallScootMarkerTime = 0.6,
	postPlayTheBallMarkerTime = 0.8,
	thirdTacklerTrackAngle = 130,
	minBallDisposalSpeed = 1.5,
	pairedMarkerTwoOffset = 2.8,
	minCollectionTime = 0.5,
	tackleTrackDistance = 1.5,
	-- reduce-ai-dummy-half-scoots: stock 0.5. How far (m) sideways a marker can be from his spot and still count as square.
	markerBufferY = 1,
	playTheBallNotProgressingTime = 1.2,
	secondTacklerTrackAngle = 45,
	playrateQuickPTB = 1.4,
	tacklePlayrateSlowPTB = 0.9,
	retireLineOffset = 10,
	tacklePlayrateQuickPTB = 1.2,
	playrateSlowPTB = 0.9,
	-- reduce-ai-dummy-half-scoots: stock 0.25. Markers usually arrive 0.3-1.5 m short of their spot (the second marker most), so they were flagged offside at most
	-- play-the-balls, which is what triggers AI scoots (shouldScoot) and marker penalties.
	markerBufferX = 1.5,
	firstTacklerTrackAngle = 0,
	timeToRemainInPostDummyHalf = 1,
	soleMarkerOffset = 2.5
}
cPlayTheBallConfig = cclass.getInstance("cPlayTheBallConfig", native.CPlayTheBallConfig)

cclass.tableMergeIntoClass(cPlayTheBallConfig, luaConfig, true)

dummyHalfSelection = {
	incapacitatedPenalty = -2000,
	distanceBonusClamp = 20,
	playingTheBallPenalty = -200000,
	longDistanceClamp = 100,
	maximumDistanceBonus = 25,
	outsideRoleDistanceModifier = 0,
	applyWingBonusWithinSideline = 13,
	maximumWingerBonusDistance = 20,
	wingBonus = 60,
	maxDistanceForRoleBonus = 25,
	passAttributeBonus = 0,
	roleBonusInfo = var_0_0 and {
		[native.EAssignedRole.Hooker] = 1000,
		[native.EAssignedRole.CentreRight] = 30,
		[native.EAssignedRole.CentreLeft] = 30,
		[native.EAssignedRole.WingerLeft] = 10,
		[native.EAssignedRole.WingerRight] = 10,
		[native.EAssignedRole.Lock] = 20,
		[native.EAssignedRole.HalfBack] = 10,
		[native.EAssignedRole.FiveEighth] = 10,
		[native.EAssignedRole.FullBack] = 15,
		[native.EAssignedRole.SecondRowLeft] = 0,
		[native.EAssignedRole.SecondRowRight] = 0,
		[native.EAssignedRole.PropLeft] = 0,
		[native.EAssignedRole.PropRight] = 0
	}
}
