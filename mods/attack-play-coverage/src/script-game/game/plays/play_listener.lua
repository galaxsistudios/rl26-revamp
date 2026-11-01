import("ai.plays.stopplay_request")
import("ai.substitutions.changespecialrole_request")
import("base.side.sidehelper")
import("script-config.rules.rules.rulesenvironment")

-- attack-play-coverage: debug log to attack_plays_debug.txt (game folder). Logs which play each side runs
-- (with the ruck's slice/zone and the tactic picked), every attacker's spot relative to the ruck 1.5 s after
-- each play-the-ball (SHAPE), and the receiving team's spots at each kick-off (KICKOFF). Turn off for release.
local DebugLog = true
local ShapeDelay = 1.5
local RoleNames = {
	[0] = "FB",
	"WL",
	"CL",
	"CR",
	"WR",
	"5/8",
	"HB",
	"PL",
	"HK",
	"PR",
	"2RL",
	"2RR",
	"LK",
	"SUB"
}

local function debugWrite(arg_0_0)
	if not DebugLog then
		return
	end

	pcall(function()
		local var_0_1 = io.open("attack_plays_debug.txt", "a")

		if var_0_1 then
			var_0_1:write(os.date("%H:%M:%S"), " ", arg_0_0, "\n")
			var_0_1:flush()
			var_0_1:close()
		end
	end)
end

local function playDirX(arg_0_0, arg_0_1)
	local var_0_0 = arg_0_0.teamKnowledgePair:get(arg_0_1).playDir

	return var_0_0.x < 0 and -1 or 1, var_0_0
end

local function sliceAndZone(arg_0_0, arg_0_1, arg_0_2)
	local var_0_0, var_0_1 = playDirX(arg_0_0, arg_0_1)
	local var_0_2 = "?"
	local var_0_3 = "?"

	pcall(function()
		var_0_2 = tostring(native.getFieldSlice(arg_0_2, var_0_1, rulesenvironment.halfFieldWidth * 2))
	end)
	pcall(function()
		var_0_3 = tostring(native.getFieldZone(arg_0_2, var_0_1))
	end)

	return var_0_2, var_0_3
end

local function selectedTactic(arg_0_0, arg_0_1)
	local var_0_0 = "?"

	pcall(function()
		local var_0_1 = arg_0_0.teamPlaySelectionOptionsPair:get(arg_0_1)

		var_0_0 = tostring(var_0_1:getSelectedPlay())
	end)

	return var_0_0
end

local function roleName(arg_0_0, arg_0_1)
	local var_0_0 = "?"

	pcall(function()
		local var_0_1 = arg_0_0:getAssignedRole(arg_0_1)

		var_0_0 = RoleNames[var_0_1:toInt()] or tostring(var_0_1)
	end)

	if var_0_0 == "?" then
		pcall(function()
			var_0_0 = tostring(arg_0_0:getAssignedRole(arg_0_1))
		end)
	end

	return var_0_0
end

-- Every player of `side` as "ROLE(dx,dy)" relative to `origin`, in that team's attacking frame
-- (+x = towards the try line they attack, +y mirrored the same way slices are). "*" = in the running play.
local function teamShape(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4)
	local var_0_0 = playDirX(arg_0_0, arg_0_3)
	local var_0_1 = {}

	for iter_0_0, iter_0_1 in arg_0_0.activeTeamPlayerIdListPair:get(arg_0_3):iter() do
		local var_0_2 = arg_0_2:getGameObject(iter_0_1)

		if var_0_2 then
			local var_0_3 = (var_0_2.pos.x - arg_0_4.x) * var_0_0
			local var_0_4 = (var_0_2.pos.y - arg_0_4.y) * var_0_0
			local var_0_5 = arg_0_0.playerPlayKnowledgePool:get(iter_0_1)
			local var_0_6 = var_0_5 and var_0_5.runningPlay and "*" or ""

			table.insert(var_0_1, {
				y = var_0_4,
				text = string.format("%s%s(%.1f,%.1f)", roleName(var_0_2, arg_0_1), var_0_6, var_0_3, var_0_4)
			})
		end
	end

	table.sort(var_0_1, function(arg_1_0, arg_1_1)
		return arg_1_0.y < arg_1_1.y
	end)

	local var_0_7 = {}

	for iter_0_2, iter_0_3 in ipairs(var_0_1) do
		table.insert(var_0_7, iter_0_3.text)
	end

	return table.concat(var_0_7, " ")
end

local function debugUpdate(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4)
	local var_0_0 = arg_0_1.knowledgeBank
	local var_0_1 = arg_0_2:getMatchProgressionEntity()
	local var_0_2 = var_0_1.attackingSide
	local var_0_3 = arg_0_2:getPlayEntityPair()

	arg_0_0.debugPlayNames = arg_0_0.debugPlayNames or {}

	for iter_0_0, iter_0_1 in ipairs(sidehelper.sides) do
		local var_0_4 = var_0_3:get(iter_0_1):getPlayName()

		if var_0_4 ~= arg_0_0.debugPlayNames[iter_0_1] then
			arg_0_0.debugPlayNames[iter_0_1] = var_0_4

			if var_0_4 and var_0_4 ~= "" then
				local var_0_5 = var_0_0.ballInfo.position
				local var_0_6, var_0_7 = sliceAndZone(var_0_0, iter_0_1, var_0_5)

				debugWrite(string.format("PLAY side=%s attacking=%s tackle=%s ballSlice=%s zone=%s tactic=%s play=%s", tostring(iter_0_1), tostring(var_0_2), tostring(var_0_1.tackleCount), var_0_6, var_0_7, selectedTactic(var_0_0, iter_0_1), tostring(var_0_4)))
			end
		end
	end

	local var_0_8 = arg_0_2:getPlayTheBallEntity()
	local var_0_9 = var_0_8 and var_0_8.playTheBallPosition

	if var_0_8 and var_0_8.playTheBallId and var_0_9 and (var_0_9.x ~= 0 or var_0_9.y ~= 0) then
		local var_0_10 = arg_0_0.debugRuck

		if not var_0_10 or math.abs(var_0_10.x - var_0_9.x) + math.abs(var_0_10.y - var_0_9.y) > 0.5 then
			arg_0_0.debugRuck = {
				x = var_0_9.x,
				y = var_0_9.y
			}
			arg_0_0.debugShapeAt = arg_0_4 + ShapeDelay
		end
	end

	if arg_0_0.debugShapeAt and arg_0_4 >= arg_0_0.debugShapeAt then
		arg_0_0.debugShapeAt = nil

		local var_0_11 = arg_0_0.debugRuck
		local var_0_12, var_0_13 = sliceAndZone(var_0_0, var_0_2, native.vec2(var_0_11.x, var_0_11.y))

		debugWrite(string.format("SHAPE side=%s tackle=%s slice=%s zone=%s play=%s | %s", tostring(var_0_2), tostring(var_0_1.tackleCount), var_0_12, var_0_13, tostring(var_0_3:get(var_0_2):getPlayName()), teamShape(var_0_0, arg_0_2, arg_0_3, var_0_2, var_0_11)))
	end

	if arg_0_0.debugKickOff then
		arg_0_0.debugKickOff = nil

		for iter_0_2, iter_0_3 in ipairs(sidehelper.sides) do
			debugWrite(string.format("KICKOFF side=%s attacking=%s (x: 0 = halfway, -50 = own try line) | %s", tostring(iter_0_3), tostring(var_0_2), teamShape(var_0_0, arg_0_2, arg_0_3, iter_0_3, {
				x = 0,
				y = 0
			})))
		end
	end

	-- Drop-outs (C-47: "everyone stays behind the goal line until the catch"): both teams at the kick, +2 s, +4 s.
	if arg_0_0.debugDropOut then
		arg_0_0.debugDropOut = nil
		arg_0_0.debugDropOutTimes = {
			arg_0_4,
			arg_0_4 + 2,
			arg_0_4 + 4
		}
		arg_0_0.debugDropOutStart = arg_0_4
	end

	local var_0_15 = arg_0_0.debugDropOutTimes

	if var_0_15 and var_0_15[1] and arg_0_4 >= var_0_15[1] then
		table.remove(var_0_15, 1)

		local var_0_16 = var_0_0.ballInfo.position

		for iter_0_4, iter_0_5 in ipairs(sidehelper.sides) do
			debugWrite(string.format("DROPOUT +%.1fs side=%s attacking=%s ball=(%.1f,%.1f) owner=%s (x from halfway, own try line -50) | %s", arg_0_4 - arg_0_0.debugDropOutStart, tostring(iter_0_5), tostring(var_0_2), var_0_16.x, var_0_16.y, tostring(arg_0_2:getBallEntity():getOwnerId(arg_0_4)), teamShape(var_0_0, arg_0_2, arg_0_3, iter_0_5, {
				x = 0,
				y = 0
			})))
		end
	end
end

-- Kick-off chase, driven from here so it doesn't depend on which place-kick controller the chasers are in
-- (stock: KickOffRunUpAi's one 20 m jog, then they stood still until the catch). For TeamChaseWindow s after
-- a kick-off, while the ball is loose, every kicking-team player but the fullback sprints at the landing spot
-- (ballInfo.nextBouncePosition, then the ball once it bounces), keeping TeamChaseFunnel of his sideways
-- distance and aiming TeamChaseStopShort m before it.
local TeamChaseWindow = 6
local TeamChaseInterval = 0.25
local TeamChaseFunnel = 0.4
local TeamChaseStopShort = 2

-- Times reaching Lua are native Time objects (tostring prints seconds, type() is userdata): use seconds.
local function toSecs(arg_0_0)
	if type(arg_0_0) == "number" then
		return arg_0_0
	end

	local var_0_0, var_0_1 = pcall(function()
		return arg_0_0:ToSeconds()
	end)

	return var_0_0 and type(var_0_1) == "number" and var_0_1 or tonumber(tostring(arg_0_0))
end

local function toFieldPos(arg_0_0)
	if type(arg_0_0) == "vec3" then
		return native.vec2(arg_0_0.x, arg_0_0.z)
	end

	return arg_0_0
end

local function teamKickOffChase(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7)
	local var_0_0 = rawget(_G, "APC_KickOffTime")
	local var_0_1 = arg_0_0.kickOffKickingSide
	local var_0_14 = arg_0_5

	arg_0_5 = toSecs(arg_0_5)

	if type(var_0_0) ~= "number" or not var_0_1 or arg_0_5 < var_0_0 or arg_0_5 - var_0_0 > TeamChaseWindow then
		return
	end

	-- (the listener can outlive a match, and game time restarts each match: drop a stale throttle)
	if arg_0_0.nextTeamChase and arg_0_0.nextTeamChase > arg_0_5 + 1 then
		arg_0_0.nextTeamChase = nil
	end

	if arg_0_0.nextTeamChase and arg_0_5 < arg_0_0.nextTeamChase then
		return
	end

	arg_0_0.nextTeamChase = arg_0_5 + TeamChaseInterval

	local function skip(arg_1_0)
		if arg_0_0.teamChaseSkipLogged ~= var_0_0 then
			arg_0_0.teamChaseSkipLogged = var_0_0

			debugWrite(string.format("CHASE kick-off team skipped at +%.2fs: %s", arg_0_5 - var_0_0, arg_1_0))
		end
	end

	local var_0_13 = arg_0_3:getBallEntity():getOwnerId(var_0_14)

	if var_0_13 then
		skip("ball owned by " .. tostring(var_0_13))

		return
	end

	local var_0_2 = arg_0_1.knowledgeBank
	local var_0_3 = var_0_2.ballInfo
	local var_0_4 = not var_0_3.hasBounced and var_0_3.nextBouncePosition and toFieldPos(var_0_3.nextBouncePosition) or toFieldPos(var_0_3.position)

	if not var_0_4 then
		skip("no landing spot")

		return
	end

	local var_0_5 = native.Time.FromSeconds(arg_0_5)
	local var_0_6 = 0

	for iter_0_0, iter_0_1 in var_0_2.activeTeamPlayerIdListPair:get(var_0_1):iter() do
		local var_0_7 = arg_0_4:getGameObject(iter_0_1)
		local var_0_8 = false

		-- skip the fullback, and the bench (the active list includes the substitutes: 18 "chasers")
		pcall(function()
			local var_0_15 = var_0_7:getAssignedRole(arg_0_3)

			var_0_8 = var_0_15 == native.EAssignedRole.FullBack or var_0_15 == native.EAssignedRole.Substitute
		end)

		local var_0_12 = false

		pcall(function()
			var_0_12 = arg_0_7 and arg_0_7:getGamer(iter_0_1) and true or false
		end)

		-- skip the fullback and any player a human is controlling
		if var_0_7 and not var_0_8 and not var_0_12 then
			local var_0_9 = var_0_7:getPlayDir().x >= 0 and 1 or -1
			local var_0_10 = native.vec2(var_0_4.x - var_0_9 * TeamChaseStopShort, var_0_4.y + (var_0_7.pos.y - var_0_4.y) * TeamChaseFunnel)
			local var_0_11 = native.CMoveToTarget(iter_0_1, var_0_10, var_0_5, arg_0_1)

			var_0_11.speed = var_0_7:getDerivedAttribute("max_speed")

			arg_0_6:add(native.CMovementRequest(iter_0_1, arg_0_2:alloc(), var_0_11))

			var_0_6 = var_0_6 + 1
		end
	end

	if arg_0_0.teamChaseLogged ~= var_0_0 then
		arg_0_0.teamChaseLogged = var_0_0

		debugWrite(string.format("CHASE kick-off team side=%s players=%d landing=(%.1f,%.1f)", tostring(var_0_1), var_0_6, var_0_4.x, var_0_4.y))
	end
end

Class("PlayListener", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	return
end)

function PlayListener.registerWithMatchSim(arg_2_0, arg_2_1)
	arg_2_1:registerUpdateable(function(...)
		arg_2_0:update(...)
	end)
	arg_2_1:registerSolidEventListener(function(...)
		arg_2_0:onStopPlayEvent(...)
	end, "TackleCommittedEvent")
	arg_2_1:registerSolidEventListener(function(...)
		arg_2_0:onStopPlayEvent(...)
	end, "DummyHalfScootEvent")
	arg_2_1:registerSolidEventListener(function(...)
		arg_2_0:onDisposalEvent(...)
	end, "DisposalEvent")
end

function PlayListener.clearPlayMakerThree(arg_7_0, arg_7_1, arg_7_2)
	for iter_7_0, iter_7_1 in ipairs(sidehelper.sides) do
		local var_7_0 = arg_7_1:getSide(iter_7_1)
		local var_7_1 = arg_7_2:getRoleInfoPool()

		for iter_7_2, iter_7_3 in var_7_0.matchClub.lineup:iterPlayers() do
			local var_7_2 = var_7_0:getIdAsset(iter_7_3)
			local var_7_3 = var_7_1:get(var_7_2)
			local var_7_4 = {}
			local var_7_5 = var_7_3:getSpecialRoles(var_7_4)

			for iter_7_4, iter_7_5 in ipairs(var_7_5) do
				if iter_7_5 == native.EClubLineupSpecialRole.PlayMaker3 then
					var_7_3:removeSpecialRole(iter_7_5)
				end
			end
		end
	end
end

function PlayListener.update(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10)
	if arg_8_0.kickOffPending then
		arg_8_0.kickOffPending = nil
		_G.APC_KickOffTime = toSecs(arg_8_9)

		debugWrite("KICKOFF stamp t=" .. tostring(arg_8_9) .. " kicking side=" .. tostring(arg_8_0.kickOffKickingSide))
	end

	local var_8_102, var_8_103 = pcall(teamKickOffChase, arg_8_0, arg_8_3, arg_8_4, arg_8_6, arg_8_7, arg_8_9, arg_8_10, arg_8_2)

	if not var_8_102 and arg_8_0.teamChaseError ~= rawget(_G, "APC_KickOffTime") then
		arg_8_0.teamChaseError = rawget(_G, "APC_KickOffTime")

		debugWrite("CHASE kick-off team ERROR " .. tostring(var_8_103))
	end

	if DebugLog then
		local var_8_100, var_8_101 = pcall(debugUpdate, arg_8_0, arg_8_3, arg_8_6, arg_8_7, arg_8_9)

		if not var_8_100 and not arg_8_0.debugErrorLogged then
			arg_8_0.debugErrorLogged = true

			debugWrite("ERROR " .. tostring(var_8_101))
		end
	end

	local var_8_0 = arg_8_3.knowledgeBank
	local var_8_1 = var_8_0.activeTeamPlayerIdListPair
	local var_8_2 = var_8_0.playerPlayKnowledgePool
	local var_8_3 = var_8_0.playerRoleInfoPool
	local var_8_4 = arg_8_6:getPlayEntityPair()

	for iter_8_0, iter_8_1 in ipairs(sidehelper.sides) do
		local var_8_5 = var_8_4:get(iter_8_1)
		local var_8_6 = var_8_5:getPlayProgression() == native.EPlayProgression.Running
		local var_8_7 = var_8_5:getPlayStartTime()
		local var_8_8 = false

		if var_8_6 and var_8_7 < arg_8_9 then
			for iter_8_2, iter_8_3 in var_8_1:get(iter_8_1):iter() do
				local var_8_9 = var_8_2:get(iter_8_3)

				ASSERT(var_8_9)

				if var_8_9 then
					if var_8_9.playRole == native.EPlayRole.PlayMaker then
						local var_8_10 = var_8_3:get(iter_8_3)
						local var_8_11 = {}
						local var_8_12 = var_8_10:getSpecialRoles(var_8_11)
						local var_8_13

						for iter_8_4, iter_8_5 in ipairs(var_8_12) do
							var_8_13 = var_8_13 or isAnyOf(iter_8_5, {
								native.EClubLineupSpecialRole.PlayMaker1,
								native.EClubLineupSpecialRole.PlayMaker2,
								native.EClubLineupSpecialRole.PlayMaker3
							})
						end

						if not var_8_13 then
							local var_8_14 = {
								side = iter_8_1,
								id = iter_8_3,
								specialRole = native.EClubLineupSpecialRole.PlayMaker3
							}

							arg_8_10:add(changespecialrole_request.ChangeSpecialRoleRequest(var_8_14))
						end
					end

					local var_8_15 = var_8_9.runningPlay

					var_8_8 = var_8_8 or var_8_15
				end
			end

			if not var_8_8 then
				arg_8_10:add(stopplay_request.StopPlayRequest({}))
				arg_8_0:clearPlayMakerThree(arg_8_5, arg_8_6)
			end
		else
			for iter_8_6, iter_8_7 in var_8_1:get(iter_8_1):iter() do
				local var_8_16 = var_8_2:get(iter_8_7)

				ASSERT(var_8_16)

				if var_8_16 and var_8_16.playRole == native.EPlayRole.PlayMaker then
					local var_8_17 = var_8_3:get(iter_8_7)
					local var_8_18 = {}
					local var_8_19 = var_8_17:getSpecialRoles(var_8_18)
					local var_8_20

					for iter_8_8, iter_8_9 in ipairs(var_8_19) do
						var_8_20 = var_8_20 or isAnyOf(iter_8_9, {
							native.EClubLineupSpecialRole.PlayMaker1,
							native.EClubLineupSpecialRole.PlayMaker2,
							native.EClubLineupSpecialRole.PlayMaker3
						})
					end

					if not var_8_20 then
						local var_8_21 = {
							side = iter_8_1,
							id = iter_8_7,
							specialRole = native.EClubLineupSpecialRole.PlayMaker3
						}

						arg_8_10:add(changespecialrole_request.ChangeSpecialRoleRequest(var_8_21))
					end
				end
			end
		end
	end
end

function PlayListener.onStopPlayEvent(arg_9_0, arg_9_1, arg_9_2, arg_9_3, arg_9_4, arg_9_5, arg_9_6, arg_9_7, arg_9_8, arg_9_9)
	local var_9_0 = arg_9_7:getMatchProgressionEntity().attackingSide

	arg_9_9:add(stopplay_request.StopPlayRequest({}))
	arg_9_0:clearPlayMakerThree(arg_9_6, arg_9_7)
end

function PlayListener.onDisposalEvent(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9)
	-- attack-play-coverage: the kick-off chase (kickoffidle_ai.lua) can't see a kick-off from the ball's own
	-- disposal info (nil for place kicks). Flag it here; update() stamps _G.APC_KickOffTime with sim time.
	pcall(function()
		local var_10_110 = arg_10_1.disposalInfo

		if var_10_110 and (var_10_110.disposalSubType == native.EDisposalSubType.KickOff or var_10_110.disposalSubType == native.EDisposalSubType.KickOffDrop) then
			arg_10_0.kickOffPending = true
			arg_10_0.kickOffKickingSide = sidehelper.getOtherSide(arg_10_7:getMatchProgressionEntity().attackingSide)
		end
	end)

	if DebugLog then
		pcall(function()
			local var_10_100 = arg_10_1.disposalInfo

			if var_10_100 and (var_10_100.disposalSubType == native.EDisposalSubType.KickOff or var_10_100.disposalSubType == native.EDisposalSubType.KickOffDrop) then
				arg_10_0.debugKickOff = true
			elseif var_10_100 and var_10_100.disposalSubType == native.EDisposalSubType.DropOut then
				arg_10_0.debugDropOut = true
			end

			-- Every pass with its game time (match it to ptb_timing_debug.txt COLLECT t= to see how long the
			-- dummy half holds the ball).
			if var_10_100 and var_10_100.disposalType == native.EDisposalType.Pass then
				local var_10_101 = arg_10_7:getPlayTheBallEntity()

				debugWrite(string.format("PASS t=%s by=%s dummyHalf=%s tackle=%s attacking=%s", tostring(var_10_100.disposalTime), tostring(var_10_100.objectId), tostring(var_10_101 and var_10_101.dummyHalfId), tostring(arg_10_7:getMatchProgressionEntity().tackleCount), tostring(arg_10_7:getMatchProgressionEntity().attackingSide)))
			end
		end)
	end

	local var_10_0 = arg_10_4.hooks
	local var_10_1 = var_10_0 and var_10_0:getHook("PlayDebugHook")

	if var_10_1 and var_10_1:getStopPlayAfterFirstPass() then
		local var_10_2 = arg_10_1.disposalInfo

		if var_10_2 and var_10_2.disposalType == native.EDisposalType.Pass then
			arg_10_9:add(stopplay_request.StopPlayRequest({}))
			arg_10_0:clearPlayMakerThree(arg_10_6, arg_10_7)
		end
	end
end
