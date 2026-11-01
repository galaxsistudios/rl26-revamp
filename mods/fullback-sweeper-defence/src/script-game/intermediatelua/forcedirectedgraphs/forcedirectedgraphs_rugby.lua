content = {
	{
		idealPositionX = 0,
		name = "BasicOffence",
		graphType = 1,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 4,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = -8,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 4,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = -8,
				yOffset = 34
			},
			{
				maxExtentsY = 1,
				name = "FullbackControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -6,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = -2,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 0.4,
				parentNodeName = "BallCompressionControl",
				influenceEndDistance = 64
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 24
			}
		}
	},
	{
		idealPositionX = 0,
		name = "LineBreakOffence",
		graphType = 21,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 2,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = -4,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 2,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = -4,
				yOffset = 34
			},
			{
				maxExtentsY = 1,
				name = "FullbackControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -6,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = -2,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				minExtentsY = 0,
				yOffset = 0,
				xOffset = -0
			},
			{
				maxExtentsY = 1,
				name = "HookerControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Hooker",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HookerControl",
				attractivenessModifier = 8,
				edgeStart = "Hooker"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 0.4,
				parentNodeName = "BallCompressionControl",
				influenceEndDistance = 64
			},
			{
				influenceAtMaxDistance = 0.5,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1.5,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 32
			}
		}
	},
	{
		idealPositionX = 0,
		name = "TutorialOffence",
		graphType = 18,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 2,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -2,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 2,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -2,
				yOffset = 34
			},
			{
				maxExtentsY = 1,
				name = "FullbackControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -12,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = -2,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 0.4,
				parentNodeName = "BallCompressionControl",
				influenceEndDistance = 64
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 24
			}
		}
	},
	{
		idealPositionX = 0,
		name = "TutorialSetupOffence",
		graphType = 19,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 3,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 3,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10,
				yOffset = 34
			},
			{
				maxExtentsY = 1,
				name = "FullbackControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -20,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 0.4,
				parentNodeName = "BallCompressionControl",
				influenceEndDistance = 64
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefence",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -20,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceCompress",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -20,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 2.5,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceCompress10m",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 2.5,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceCompress10mLastTackle",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -14,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 2.5,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "TutorialDefence",
		graphType = 17,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -10,
				xOffset = -10,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -10,
				xOffset = -10,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -25,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceSlideLeft",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -20,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1.25,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1.5,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1.5,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1.5,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1.25,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceSlideRight",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -20,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1.25,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1.5,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1.5,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1.5,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1.25,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceDropWings",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				maxExtentsY = 0,
				name = "LeftSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = -34
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerLeft",
				name = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerRight",
				name = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -20,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControlDropped"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 0.8,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0.8,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "RightSidelineControlDropped",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceCompress",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -25,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 2.5,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefence",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -25,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "ScrumDefence",
		graphType = 15,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 10.5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -0.5,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				maxExtentsY = 0,
				name = "LeftSidelineSecondaryControl",
				maxExtentsX = 12.5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -0.5,
				xOffset = -12.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 10.5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -0.5,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineSecondaryControl",
				maxExtentsX = 12.5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -0.5,
				xOffset = -12.5,
				yOffset = 34
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0.5,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 0.5,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0.5,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineSecondaryControl"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0.5,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0.5,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0.5,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "RightSidelineSecondaryControl",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.8,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 22
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceSlideLeft",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -25,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1.25,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1.5,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1.5,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1.5,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1.25,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceSlideRight",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -25,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1.25,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1.5,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1.5,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1.5,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1.25,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceDropWings",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				maxExtentsY = 0,
				name = "LeftSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = -34
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerLeft",
				name = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerRight",
				name = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -25,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControlDropped"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 0.8,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0.8,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "RightSidelineControlDropped",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefence10m",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceSlideLeft10m",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1.25,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1.5,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1.5,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1.5,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1.25,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceSlideRight10m",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1.25,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1.5,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1.5,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1.5,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1.25,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceDropWings10m",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				maxExtentsY = 0,
				name = "LeftSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = -34
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerLeft",
				name = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerRight",
				name = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -20,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControlDropped"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0.8,
				edgeStart = "FullbackControl"
			},
			{
				edgeEnd = "RightSidelineControlDropped",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefence10m",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceCompress10m",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 2.5,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceSlideLeft10m",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1.25,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1.5,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1.5,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1.5,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1.25,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceSlideRight10m",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1.25,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1.5,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1.5,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1.5,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1.25,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceDropWings10m",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				maxExtentsY = 0,
				name = "LeftSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = -34
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerLeft",
				name = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerRight",
				name = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -40,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControlDropped"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0.8,
				edgeStart = "FullbackControl"
			},
			{
				edgeEnd = "RightSidelineControlDropped",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefence10mLastTackle",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -14,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceSlideLeft10mLastTackle",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -14,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1.25,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1.5,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1.5,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1.5,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1.25,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceSlideRight10mLastTackle",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -14,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1.25,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1.5,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1.5,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1.5,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1.25,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicDefenceDropWings10mLastTackle",
		graphType = 0,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = -34
			},
			{
				maxExtentsY = 0,
				name = "LeftSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = -34
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerLeft",
				name = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerRight",
				name = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -7,
				yOffset = 34
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -14,
				yOffset = 0
			},
			{
				minExtentsX = -0.5,
				name = "BallAttractionControl",
				maxExtentsX = 0.5,
				nodeType = "OffsetXY",
				maxExtentsY = 0.5,
				xOffset = 0,
				minExtentsY = -0.5,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0.8,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.8,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControlDropped"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 0.8,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0.8,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "RightSidelineControlDropped",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 8
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.2,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.8,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefence10mLastTackle",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -15,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceCompress10mLastTackle",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -15,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 2.5,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceSlideLeft10mLastTackle",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -15,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceSlideRight10mLastTackle",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -15,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1.25,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1.5,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1.5,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1.5,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1.25,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallDefenceDropWings10mLastTackle",
		graphType = 2,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				maxExtentsY = 0,
				name = "LeftSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = -34
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerLeft",
				name = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				isPartOfLine = false,
				primaryRole = "WingerRight",
				name = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControlDropped",
				maxExtentsX = 5,
				nodeType = "OffsetX",
				hardLimit = "FullBack",
				minExtentsY = 0,
				minExtentsX = -3,
				xOffset = -37,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -15,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControlDropped"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 0.8,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0.8,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "RightSidelineControlDropped",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "BasicPlayTheBallOffence",
		graphType = 3,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10, -- attack-play-coverage (one owner per file): stock -14. Backs stood 12-14 m behind the ruck
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10, -- attack-play-coverage (one owner per file): stock -14
				yOffset = 34
			},
			{
				maxExtentsY = 1,
				name = "FullbackControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "FullBack",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -10,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = -2,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 0.4,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 64
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.5,
				parentNodeName = "BallCompressionControl",
				influenceEndDistance = 24
			}
		}
	},
	{
		idealPositionX = 0,
		name = "ScrumOffence",
		graphType = 16,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 2,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = -14,
				yOffset = -34
			},
			{
				maxExtentsY = 0,
				name = "LeftSidelineSecondaryControl",
				maxExtentsX = 2,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = -16,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 2,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = -14,
				yOffset = 34
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineSecondaryControl",
				maxExtentsX = 2,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = -16,
				yOffset = 34
			},
			{
				minExtentsX = -2,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineSecondaryControl"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "RightSidelineSecondaryControl",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 0.4,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 64
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 0.6,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 24
			}
		}
	},
	{
		idealPositionX = 0,
		name = "TackleTrainingOffence",
		graphType = 1,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 4,
				nodeType = "OffsetXY",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -4,
				xOffset = -4,
				yOffset = -12
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				minExtentsX = -4,
				name = "RightSidelineControl",
				maxExtentsX = 4,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -4,
				minExtentsY = 0,
				yOffset = 12
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.75,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.75,
				edgeStart = "FullBack"
			}
		},
		effectors = {}
	},
	{
		idealPositionX = 0,
		name = "TackleTrainingDefence",
		graphType = 1,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 4,
				nodeType = "OffsetXY",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = -4,
				xOffset = -4,
				yOffset = -12
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				minExtentsX = -4,
				name = "RightSidelineControl",
				maxExtentsX = 4,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -4,
				minExtentsY = 0,
				yOffset = 12
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0.75,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 0.75,
				edgeStart = "FullBack"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.25,
				influenceEndDistance = 16
			},
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "XPositionModifier",
				influenceAtMinDistance = 1.2,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeGeneralGameplay",
		graphType = 4,
		nodes = {
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine2",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine3",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 4,
				name = "PlayTheBallControl",
				maxExtentsX = 2,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -4,
				minExtentsX = -2,
				xOffset = -10,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "DeadBallLineControl",
				maxExtentsX = 2,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = -2,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = 4,
				name = "DeadBallLineControl2",
				maxExtentsX = 2,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -4,
				minExtentsX = -2,
				xOffset = 10,
				yOffset = -10
			},
			{
				maxExtentsY = 4,
				name = "DeadBallLineControl3",
				maxExtentsX = 2,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -4,
				minExtentsX = -2,
				xOffset = 10,
				yOffset = 10
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "PlayTheBallControl",
				attractivenessModifier = 1,
				edgeStart = "RefereePlayTheBall"
			},
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "DeadBallLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine2"
			},
			{
				edgeEnd = "DeadBallLineControl3",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine3"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereePlayTheBall",
		graphType = 5,
		nodes = {
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -10,
				yOffset = -2
			},
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl2",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -10,
				yOffset = 2
			},
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereePlayTheBall2",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine2",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine3",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl2",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 10
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl3",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = -10
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "DeadBallLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine2"
			},
			{
				edgeEnd = "DeadBallLineControl3",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine3"
			},
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "RefereePlayTheBall2",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl2"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeScrum",
		graphType = 6,
		nodes = {
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -3,
				yOffset = -2
			},
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl2",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -3,
				yOffset = 2
			},
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereePlayTheBall2",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -0.5,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 0.5,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "RefereePlayTheBall2",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl2"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeTapRestart",
		graphType = 7,
		nodes = {
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -3,
				yOffset = -3
			},
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl2",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -3,
				yOffset = 3
			},
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereePlayTheBall2",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine2",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine3",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl2",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 20
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl3",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = -20
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 10,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 10,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "DeadBallLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine2"
			},
			{
				edgeEnd = "DeadBallLineControl3",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine3"
			},
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "RefereePlayTheBall2",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl2"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeKickOff",
		graphType = 8,
		nodes = {
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = 3,
				yOffset = 5
			},
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -1,
				nodeType = "OffsetY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -60,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -55,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -55,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeKickToTouchLeft",
		graphType = 9,
		nodes = {
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -3,
				yOffset = -4
			},
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -20,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -20,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -20,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeKickToTouchRight",
		graphType = 10,
		nodes = {
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -3,
				yOffset = 4
			},
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -20,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -20,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -20,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeLineDropOut",
		graphType = 11,
		nodes = {
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -2,
				yOffset = -4
			},
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl2",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -2,
				yOffset = 4
			},
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereePlayTheBall2",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -50,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -50,
				yOffset = -35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -50,
				yOffset = 35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "RefereePlayTheBall2",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl2"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeConversionKickLeft",
		graphType = 12,
		nodes = {
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "PlayTheBallControl",
				maxExtentsX = -1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -3,
				yOffset = 5
			},
			{
				maxExtentsY = 0,
				name = "DeadBallLineControl",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -55,
				yOffset = -2
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -55,
				yOffset = 2
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			}
		},
		edges = {
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "RefereeDeadBallLine",
				attractivenessModifier = 1,
				edgeStart = "DeadBallLineControl"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeConversionKickRight",
		graphType = 13,
		nodes = {
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "PlayTheBallControl",
				maxExtentsX = -1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -3,
				yOffset = -5
			},
			{
				maxExtentsY = 0,
				name = "DeadBallLineControl",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -55,
				yOffset = -2
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -55,
				yOffset = 2
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			}
		},
		edges = {
			{
				edgeEnd = "RefereePlayTheBall",
				attractivenessModifier = 1,
				edgeStart = "PlayTheBallControl"
			},
			{
				edgeEnd = "RefereeDeadBallLine",
				attractivenessModifier = 1,
				edgeStart = "DeadBallLineControl"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeGeneralGameplayNonStandard",
		graphType = 4,
		nodes = {
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine2",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine3",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 4,
				name = "DeadBallLineControl",
				maxExtentsX = 2,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -4,
				minExtentsX = -2,
				xOffset = 20,
				yOffset = 0
			},
			{
				maxExtentsY = 4,
				name = "DeadBallLineControl2",
				maxExtentsX = 2,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -4,
				minExtentsX = -2,
				xOffset = 20,
				yOffset = -10
			},
			{
				maxExtentsY = 4,
				name = "DeadBallLineControl3",
				maxExtentsX = 2,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -4,
				minExtentsX = -2,
				xOffset = 20,
				yOffset = 10
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "DeadBallLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine2"
			},
			{
				edgeEnd = "DeadBallLineControl3",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine3"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereePlayTheBallNonStandard",
		graphType = 5,
		nodes = {
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine2",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine3",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl2",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 20
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl3",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = -20
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "DeadBallLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine2"
			},
			{
				edgeEnd = "DeadBallLineControl3",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine3"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeScrumNonStandard",
		graphType = 6,
		nodes = {
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -0.5,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 0.5,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeTapRestartNonStandard",
		graphType = 7,
		nodes = {
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine2",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine3",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl2",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 20
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl3",
				maxExtentsX = -0.5,
				nodeType = "OffsetX",
				hardLimit = "RefereeTryLine",
				minExtentsY = 1,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = -20
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 10,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 10,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "DeadBallLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine2"
			},
			{
				edgeEnd = "DeadBallLineControl3",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine3"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeKickOffNonStandard",
		graphType = 8,
		nodes = {
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = 3,
				yOffset = 5
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -55,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -55,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "PlayTheBallControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeKickToTouchLeftNonStandard",
		graphType = 9,
		nodes = {
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -20,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -20,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -20,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeKickToTouchRightNonStandard",
		graphType = 10,
		nodes = {
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -20,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -20,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -20,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeLineDropOutNonStandard",
		graphType = 11,
		nodes = {
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = -1,
				name = "DeadBallLineControl",
				maxExtentsX = -1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = 1,
				minExtentsX = 1,
				xOffset = -50,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -50,
				yOffset = -35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = -50,
				yOffset = 35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeConversionKickLeftNonStandard",
		graphType = 12,
		nodes = {
			{
				maxExtentsY = 0,
				name = "DeadBallLineControl",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -55,
				yOffset = -2
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -55,
				yOffset = 2
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			}
		},
		edges = {
			{
				edgeEnd = "RefereeDeadBallLine",
				attractivenessModifier = 1,
				edgeStart = "DeadBallLineControl"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeConversionKickRightNonStandard",
		graphType = 13,
		nodes = {
			{
				maxExtentsY = 0,
				name = "DeadBallLineControl",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = 10,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -55,
				yOffset = -2
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 0,
				nodeType = "Fixed",
				hardLimit = "Referee",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -55,
				yOffset = 2
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			}
		},
		edges = {
			{
				edgeEnd = "RefereeDeadBallLine",
				attractivenessModifier = 1,
				edgeStart = "DeadBallLineControl"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "RefereeTutorial",
		graphType = 4,
		nodes = {
			{
				name = "RefereePlayTheBall",
				primaryRole = "RefereePlayTheBall",
				nodeType = "Floating"
			},
			{
				name = "RefereeDeadBallLine",
				primaryRole = "RefereeDeadBallLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				name = "RefereeSideLine2",
				primaryRole = "RefereeSideLine",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 1,
				name = "PlayTheBallControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = -25,
				yOffset = 0
			},
			{
				maxExtentsY = 1,
				name = "DeadBallLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetXY",
				hardLimit = "Referee",
				minExtentsY = -1,
				minExtentsX = -1,
				xOffset = 25,
				yOffset = 0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = 35,
				minExtentsY = -0
			},
			{
				maxExtentsY = 0,
				name = "SideLineControl2",
				maxExtentsX = 1,
				nodeType = "OffsetX",
				hardLimit = "Referee",
				minExtentsX = -1,
				xOffset = 0,
				yOffset = -35,
				minExtentsY = -0
			}
		},
		edges = {
			{
				edgeEnd = "PlayTheBallControl",
				attractivenessModifier = 1,
				edgeStart = "RefereePlayTheBall"
			},
			{
				edgeEnd = "DeadBallLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeDeadBallLine"
			},
			{
				edgeEnd = "SideLineControl",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine"
			},
			{
				edgeEnd = "SideLineControl2",
				attractivenessModifier = 1,
				edgeStart = "RefereeSideLine2"
			}
		},
		effectors = {},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "TapRestartDefence",
		graphType = 20,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				maxExtentsY = 3,
				name = "FullbackControl",
				maxExtentsX = 3,
				nodeType = "OffsetXY",
				hardLimit = "Default",
				minExtentsY = -3,
				minExtentsX = -8,
				xOffset = -25,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 0,
				edgeStart = "FullBack"
			},
			{
				edgeEnd = "FullbackControl",
				attractivenessModifier = 10,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	},
	{
		idealPositionX = 0,
		name = "TapRestartDefence10m",
		graphType = 20,
		nodes = {
			{
				maxExtentsY = 0,
				name = "LeftSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = -34
			},
			{
				name = "WingerLeft",
				primaryRole = "WingerLeft",
				nodeType = "Floating"
			},
			{
				name = "CentreLeft",
				primaryRole = "CentreLeft",
				nodeType = "Floating"
			},
			{
				name = "PropLeft",
				primaryRole = "PropLeft",
				nodeType = "Floating"
			},
			{
				name = "SecondRowLeft",
				primaryRole = "SecondRowLeft",
				nodeType = "Floating"
			},
			{
				name = "FiveEighth",
				primaryRole = "FiveEighth",
				nodeType = "Floating"
			},
			{
				name = "FullBack",
				primaryRole = "FullBack",
				nodeType = "Floating"
			},
			{
				name = "Hooker",
				primaryRole = "Hooker",
				nodeType = "Floating"
			},
			{
				name = "HalfBack",
				primaryRole = "HalfBack",
				nodeType = "Floating"
			},
			{
				name = "PropRight",
				primaryRole = "PropRight",
				nodeType = "Floating"
			},
			{
				name = "SecondRowRight",
				primaryRole = "SecondRowRight",
				nodeType = "Floating"
			},
			{
				name = "Lock",
				primaryRole = "Lock",
				nodeType = "Floating"
			},
			{
				name = "CentreRight",
				primaryRole = "CentreRight",
				nodeType = "Floating"
			},
			{
				name = "WingerRight",
				primaryRole = "WingerRight",
				nodeType = "Floating"
			},
			{
				maxExtentsY = 0,
				name = "RightSidelineControl",
				maxExtentsX = 0,
				nodeType = "OffsetX",
				hardLimit = "Default",
				minExtentsY = 0,
				minExtentsX = 0,
				xOffset = -10.5,
				yOffset = 34
			},
			{
				minExtentsX = 0,
				name = "BallCompressionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = 0,
				minExtentsY = 0,
				yOffset = 0
			},
			{
				minExtentsX = 0,
				name = "BallAttractionControl",
				maxExtentsX = 0,
				nodeType = "OffsetXY",
				maxExtentsY = 0,
				xOffset = -1.5,
				minExtentsY = 0,
				yOffset = 0
			}
		},
		edges = {
			{
				edgeEnd = "WingerLeft",
				attractivenessModifier = 1,
				edgeStart = "LeftSidelineControl"
			},
			{
				edgeEnd = "CentreLeft",
				attractivenessModifier = 1,
				edgeStart = "WingerLeft"
			},
			{
				edgeEnd = "FiveEighth",
				attractivenessModifier = 1,
				edgeStart = "CentreLeft"
			},
			{
				edgeEnd = "SecondRowLeft",
				attractivenessModifier = 1,
				edgeStart = "FiveEighth"
			},
			{
				edgeEnd = "PropLeft",
				attractivenessModifier = 1,
				edgeStart = "SecondRowLeft"
			},
			{
				edgeEnd = "Hooker",
				attractivenessModifier = 1,
				edgeStart = "PropLeft"
			},
			{
				edgeEnd = "FullBack",
				attractivenessModifier = 1,
				edgeStart = "Hooker"
			},
			{
				edgeEnd = "PropRight",
				attractivenessModifier = 1,
				edgeStart = "Lock"
			},
			{
				edgeEnd = "SecondRowRight",
				attractivenessModifier = 1,
				edgeStart = "PropRight"
			},
			{
				edgeEnd = "HalfBack",
				attractivenessModifier = 1,
				edgeStart = "SecondRowRight"
			},
			{
				edgeEnd = "CentreRight",
				attractivenessModifier = 1,
				edgeStart = "HalfBack"
			},
			{
				edgeEnd = "WingerRight",
				attractivenessModifier = 1,
				edgeStart = "CentreRight"
			},
			{
				edgeEnd = "RightSidelineControl",
				attractivenessModifier = 1,
				edgeStart = "WingerRight"
			},
			{
				edgeEnd = "Lock",
				attractivenessModifier = 1,
				edgeStart = "FullBack"
			}
		},
		effectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "QuadraticOut",
				nodeType = "AttractionModifier",
				influenceAtMinDistance = 1.2,
				parentNodeName = "BallAttractionControl",
				influenceEndDistance = 16
			}
		},
		playerEffectors = {
			{
				influenceAtMaxDistance = 0,
				influenceStartDistance = 0,
				easingType = "SineOut",
				nodeType = "YPositionModifier",
				influenceAtMinDistance = 0.4,
				influenceEndDistance = 12
			}
		}
	}
}
