import("core.foundation.cclass")

luaConfig = {
	-- attack-play-coverage: stock 1. Rating cost per slice (4.9 m strip) between the ruck and the strip a play
	-- was written for. At 1 a play 3-5 strips away beat a matching one (a zone miss costs 10), putting runners
	-- where the play never meant them to be.
	sliceProximityWeight = 4,
	zoneProximityWeight = 10,
	focusPositionRenderLerpValue = 1
}
cPlaySelectionConfig = cclass.getInstance("cPlaySelectionConfig", native.CPlaySelectionConfig)

cclass.tableMergeIntoClass(cPlaySelectionConfig, luaConfig, true)
