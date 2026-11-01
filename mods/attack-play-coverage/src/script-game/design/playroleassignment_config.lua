import("core.foundation.cclass")

luaConfig = {
	nonForwardPositionCost = 20,
	nonBackPositionCost = 20,
	wrongAssignedRoleCost = 10,
	distanceCostPerMetre = 1,
	nonFullbackPositionCost = 40,
	wrongPlayRoleCost = 1000,
	-- attack-play-coverage: stock 12.5. Cost of giving a play's playmaker role (the kicker in every kick play)
	-- to a non-playmaker, against 1 per metre: a forward 13 m closer beat the halves, so forwards took the
	-- last-tackle kick (C-49) and ran it.
	nonPlayMakerPositionCost = 40
}
cPlayRoleAssignmentConfig = cclass.getInstance("cPlayRoleAssignmentConfig", native.CPlayRoleAssignmentConfig)

cclass.tableMergeIntoClass(cPlayRoleAssignmentConfig, luaConfig, true)
