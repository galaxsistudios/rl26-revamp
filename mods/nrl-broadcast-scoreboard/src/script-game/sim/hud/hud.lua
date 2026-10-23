import("app.club.club_helper")
import("app.noesis.util.nvm_team")
import("core.foundation.tablex")
import("core.profile.profile")
import("sim.hud.hud_featurestack")
import("sim.hud.hud_helper")

local var_0_0 = native:getEnvironment():argExists("nohud")
local var_0_1 = {
	"logotransition"
}

GenericTheme = {
	"DefaultHUDResources"
}
CompetitionThemes = {
	[native.CareerCompetitionIdEnum.League_BetfredChampionship] = {
		"SuperLeagueHUDResources"
	},
	[native.CareerCompetitionIdEnum.League_SuperLeague] = {
		"SuperLeagueHUDResources"
	},
	[native.CareerCompetitionIdEnum.League_BetfredLeague1] = {
		"SuperLeagueHUDResources"
	},
	[native.CareerCompetitionIdEnum.League_WSL] = {
		"SuperLeagueHUDResources"
	},
	[native.CareerCompetitionIdEnum.League_QLDCup] = {
		"QLDCupHUDResources"
	},
	[native.CareerCompetitionIdEnum.Tournament_StateOfOrigin] = {
		"StateOfOriginHUDResources"
	},
	[native.CareerCompetitionIdEnum.Tournament_RLWC2026Men] = {
		"RLWC26HUDResources"
	},
	[native.CareerCompetitionIdEnum.Tournament_RLWC2026Women] = {
		"RLWC26HUDResources"
	}
}

Class("Hud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3)
	arg_1_0.elements = {}
	arg_1_0.updateOrder = {}
	arg_1_0.nogamehud = arg_1_2.nogamehud
	arg_1_0.uiServices = arg_1_3
	arg_1_0.homeTeamNVM = nvm_team.NVMTeam()
	arg_1_0.awayTeamNVM = nvm_team.NVMTeam()
	arg_1_0.featureStack = hud_featurestack.HudFeatureStack()
end)

function Hud.init(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
	if arg_2_3.playGo then
		return
	end

	local var_2_0 = arg_2_3.home
	local var_2_1 = arg_2_3.away
	local var_2_2, var_2_3 = club_helper.getClubLogos(arg_2_1, arg_2_3, "large_mirrored")

	arg_2_0.homeTeamNVM:populateWithMatchClubAndTeamConfig(var_2_0, var_2_2)
	arg_2_0.awayTeamNVM:populateWithMatchClubAndTeamConfig(var_2_1, var_2_3)

	-- nrl-broadcast-scoreboard: the unused ui/club_logos/hud_score crops only exist
	-- for icon clubs; decal (custom) clubs keep TeamLogo via the XAML fallback.
	-- .icon may be a native string (only ever concatenated by stock code), so it
	-- is never type-checked, and every native access is pcall-guarded so a
	-- failure here can only cost the crest, never the HUD.
	local var_2_textureManager = arg_2_1:getTextureManager()
	local var_2_decalRender = arg_2_1:getDecalRender()

	for iter_2_0, iter_2_1 in ipairs({
		{
			var_2_0,
			arg_2_3.homeTeamConfig,
			arg_2_0.homeTeamNVM
		},
		{
			var_2_1,
			arg_2_3.awayTeamConfig,
			arg_2_0.awayTeamNVM
		}
	}) do
		local var_2_club, var_2_teamConfig, var_2_nvm = iter_2_1[1], iter_2_1[2], iter_2_1[3]
		local var_2_ok, var_2_decalIdOrIcon = pcall(function()
			return var_2_club.decalIdOrIcon
		end)

		if not var_2_ok or var_2_decalIdOrIcon == nil then
			var_2_ok, var_2_decalIdOrIcon = pcall(function()
				return var_2_club.identity.decalIdOrIcon
			end)
		end

		local var_2_iconOk, var_2_icon = pcall(function()
			return var_2_decalIdOrIcon.icon
		end)
		local var_2_dbg = "icon=" .. (var_2_iconOk and type(var_2_icon) .. ":" .. tostring(var_2_icon) or "err")

		var_2_nvm.scoreTextures = {}

		if var_2_ok and var_2_iconOk and var_2_icon ~= nil and var_2_icon ~= "" then
			-- A: same engine call that loads TeamLogo, with the hud_score format
			local var_2_texOk, var_2_tex = pcall(function()
				return var_2_teamConfig:createDecalIdOrIconTexture(var_2_decalIdOrIcon, var_2_decalRender, var_2_textureManager, "hud_score")
			end)

			var_2_dbg = var_2_dbg .. " A:" .. (var_2_texOk and (var_2_tex ~= nil and "tex" or "nil") or "err " .. tostring(var_2_tex))

			if var_2_texOk and var_2_tex ~= nil then
				table.insert(var_2_nvm.scoreTextures, {
					label = "A",
					texture = var_2_tex
				})
			end

			-- B: load by path, like nvm_careerhome does for Club_Logos/256
			var_2_texOk, var_2_tex = pcall(function()
				return var_2_textureManager:load("ui/club_logos/hud_score/" .. var_2_icon .. ".texture")
			end)

			var_2_dbg = var_2_dbg .. " B:" .. (var_2_texOk and (var_2_tex ~= nil and "tex" or "nil") or "err " .. tostring(var_2_tex))

			if var_2_texOk and var_2_tex ~= nil then
				table.insert(var_2_nvm.scoreTextures, {
					label = "B",
					texture = var_2_tex
				})
			end
		end

		var_2_nvm.scoreDebugBase = var_2_dbg
		var_2_nvm.ScoreDebug = var_2_dbg
	end

	local var_2_4 = arg_2_1:getNoesis()
	local var_2_5 = native.paNVMGameplayHud()
	local var_2_6 = var_2_4:loadViewWithVM("Workspace/Views/HUD/Rugby/paGameplayHudControl", var_2_5, native.ENoesisViewManagerLayer.POST_SCENE, native.CNoesisViewManager.DefaultPriority)

	var_2_5:setSex(arg_2_3.sex.isFemale)

	arg_2_0[hud_helper.HUD_IDENTIFIERS.gameplay] = var_2_5
	arg_2_0.gameplayHudView = var_2_6
	arg_2_0.featureStack[hud_helper.HUD_IDENTIFIERS.gameplay] = var_2_5

	local var_2_7 = arg_2_3.stateOfTheSeason.competitionId
	local var_2_8 = CompetitionThemes[var_2_7] or GenericTheme

	var_2_6:setTheme("Hud/" .. var_2_8[1])
end

function Hud.registerWithMatchSim(arg_3_0, arg_3_1)
	for iter_3_0, iter_3_1 in pairs(arg_3_0.elements) do
		if iter_3_1.registerWithMatchSim then
			iter_3_1:registerWithMatchSim(arg_3_1)
		end
	end
end

function Hud.registerWithHud(arg_4_0, arg_4_1, arg_4_2)
	arg_4_0.elements[arg_4_2] = arg_4_1

	local var_4_0 = arg_4_0.updateOrder

	var_4_0[#var_4_0 + 1] = arg_4_2
end

function Hud.getElement(arg_5_0, arg_5_1)
	if var_0_0 and not tablex.contains(var_0_1, arg_5_1) then
		return nil
	end

	return arg_5_0.elements[arg_5_1]
end

function Hud.dispose(arg_6_0, arg_6_1)
	if arg_6_0.homeTeamNVM then
		arg_6_0.homeTeamNVM:dispose(true)
	end

	if arg_6_0.awayTeamNVM then
		arg_6_0.awayTeamNVM:dispose(true)
	end

	for iter_6_0, iter_6_1 in pairs(arg_6_0.elements) do
		iter_6_1:dispose(arg_6_1)
	end

	arg_6_0.featureStack[hud_helper.HUD_IDENTIFIERS.gameplay] = nil

	if arg_6_0.gameplayHudView ~= nil then
		arg_6_0.gameplayHudView:release()

		arg_6_0.gameplayHudView = nil

		arg_6_0[hud_helper.HUD_IDENTIFIERS.gameplay]:dispose()

		arg_6_0[hud_helper.HUD_IDENTIFIERS.gameplay] = nil
	end
end

function Hud.setVisible(arg_7_0, arg_7_1)
	arg_7_0[hud_helper.HUD_IDENTIFIERS.gameplay].isVisible = arg_7_1

	if var_0_0 then
		return
	end

	arg_7_0.show = arg_7_1
end

function Hud.update(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, arg_8_8, arg_8_9, arg_8_10, arg_8_11)
	local var_8_0 = arg_8_8 * arg_8_2.gameServices.timeFactor

	if arg_8_0.nogamehud or var_8_0 == 0 then
		return
	end

	if arg_8_0.homeTeamNVM then
		arg_8_0.homeTeamNVM:update()
	end

	if arg_8_0.awayTeamNVM then
		arg_8_0.awayTeamNVM:update()
	end

	local var_8_1 = arg_8_0.elements
	local var_8_2 = arg_8_0.uiServices

	for iter_8_0, iter_8_1 in ipairs(arg_8_0.updateOrder) do
		if not var_0_0 or tablex.contains(var_0_1, iter_8_1) then
			profile.push(iter_8_1)

			local var_8_3 = var_8_1[iter_8_1]

			if var_8_3.update then
				var_8_3:update(arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, arg_8_7, var_8_0, arg_8_9, arg_8_10, var_8_2, arg_8_11)
			end

			profile.pop(iter_8_1)
		end
	end

	arg_8_0.featureStack:update(arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6, var_8_0, arg_8_9, arg_8_10, arg_8_11)
end

function Hud.render(arg_9_0, arg_9_1, arg_9_2, arg_9_3)
	if arg_9_0.nogamehud then
		return
	end

	local var_9_0 = arg_9_0.elements
	local var_9_1 = arg_9_0.uiServices

	for iter_9_0, iter_9_1 in ipairs(arg_9_0.updateOrder) do
		if not var_0_0 or tablex.contains(var_0_1, iter_9_1) then
			profile.push(iter_9_1)

			local var_9_2 = var_9_0[iter_9_1]

			if var_9_2.render then
				var_9_2:render(arg_9_1, arg_9_2, arg_9_3)
			end

			profile.pop(iter_9_1)
		end
	end
end
