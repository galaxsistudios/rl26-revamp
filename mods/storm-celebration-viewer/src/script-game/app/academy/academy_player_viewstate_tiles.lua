import("app.academy.academy_communitystate_playerstate_download_substate")
import("app.academy.academy_communitystate_playerstate_viewstate_rate_substate")
import("app.academy.academy_communitystate_playerstate_viewstate_report_substate")
import("app.academy.academy_player_createcustom_clubselect_state")
import("app.academy.academy_player_viewstate_appearance_state")
import("app.academy.academy_player_viewstate_copyappearance_state")
import("app.player.player_viewstate_attributes_state")
import("app.player.player_viewstate_identity_state")
import("app.player.player_viewstate_sharing_state")
import("app.player.player_viewstate_statistics_state")
import("app.playermodel.playermodel_animation_emotion")
import("app.playermodel.playermodel_camera_aide")
import("base.ui.optionmenu.optionmenu_aide")
import("base.ui.optionmenu.optionmenu_state")

local var_0_0 = native.standalone

-- storm-celebration-viewer: plays a Storm promo try celebration (animset cutsceneStormPromo,
-- loaded by playermodel_resources.lua) on the menu model, looped until the menu is left.
-- The cutscene cameras are not used; the model keeps the normal menu camera.
local var_0_celebrations = {
	{ value = "jack_howarth_celebration", face = "face_storm_jack_howarth_01", label = "Jack Howarth" },
	{ value = "moses_leo_celebration", face = "face_storm_moses_leo_01", label = "Moses Leo" },
	{ value = "jahrome_hughes_celebration", face = "face_storm_jahrome_hughes_01", label = "Jahrome Hughes" },
	{ value = "cameron_munster_celebration", face = "face_storm_cameron_munster_01", label = "Cameron Munster" },
	{ value = "harry_grant_celebration", face = "face_storm_harry_grant_01", label = "Harry Grant" },
	{ value = "shawn_blore_celebration", face = "face_storm_shawn_blore_01", label = "Shawn Blore" },
	{ value = "alec_macdonald_celebration", face = "face_storm_alec_macdonald_01", label = "Alec MacDonald" },
	{ value = "tui_kamikamica_celebration", face = "face_storm_idle_01", label = "Tui Kamikamica" },
	{ value = "tyran_wishart_celebration", face = "face_storm_tyran_wishart_01", label = "Tyran Wishart" },
	{ value = "nick_meaney_celebration", face = "face_storm_nick_meaney_01", label = "Nick Meaney" },
	{ value = "joe_chan_celebration", face = "face_storm_31_joe_chan", label = "Joe Chan" },
	{ value = "josh_king_celebration", face = "face_storm_josh_king_01", label = "Josh King" },
	{ value = "will_warbrick_celebration", face = "face_storm_will_warbrick_01", label = "Will Warbrick" },
	{ value = "xavier_coates_celebration", face = "face_storm_37_xavier_coates", label = "Xavier Coates" },
	{ value = "sua_faalogo_celebration", face = "face_storm_sua_faalogo_01", label = "Sua Fa'alogo" }
}
local var_0_faceByClip = {}

for iter_0_0, iter_0_1 in ipairs(var_0_celebrations) do
	var_0_faceByClip[iter_0_1.value] = iter_0_1.face
end

local var_0_framings = {
	{ value = "FullBody_OutsideOfAppearance", label = "Full Body" },
	{ value = "FullBody_OutsideOfAppearance_Centred", label = "Full Body (Centred)" },
	{ value = "HeadAndShoulders_OutsideOfAppearance", label = "Head & Shoulders" }
}
local var_0_celebrationBlendFrames = 10
local var_0_faceBlendFrames = 7
local var_0_optionMenuState = optionmenu_state.OptionMenuState

-- The menu emotion system only knows emotiongroups_ui, so the clips' emotion_cs_storm_* events
-- do nothing here. While forcedFaceAnim is set the face layer plays that clip instead of the
-- emotion group (forcedFaceRestart restarts it, to stay in sync with the body loop).
local var_0_emotion = playermodel_animation_emotion.PlayerModelAnimationEmotion

if not var_0_emotion.stormCelebrationViewerWrapped then
	var_0_emotion.stormCelebrationViewerWrapped = true

	local var_0_emotionUpdate = var_0_emotion.update

	function var_0_emotion.update(arg_0_0, arg_0_1, arg_0_2)
		local var_0_face = arg_0_0.forcedFaceAnim

		if not var_0_face then
			return var_0_emotionUpdate(arg_0_0, arg_0_1, arg_0_2)
		end

		arg_0_0.forceEvaluate = false

		local var_0_command = arg_0_0.playerAnimation:getPrimaryEmotionCommand()

		if arg_0_0.forcedFaceRestart or not var_0_command or var_0_command.anim ~= var_0_face then
			arg_0_0.forcedFaceRestart = false

			arg_0_0.playerAnimation:executeEmotionCommand(arg_0_0.playerAnimation:createBlendCommand(var_0_face, {
				looping = true,
				time = var_0_faceBlendFrames
			}))
		end
	end
end

local function var_0_setForcedFace(arg_0_0, arg_0_1)
	local var_0_emotionInstance = arg_0_0.playerModelAnimation.emotion

	if var_0_emotionInstance.forcedFaceAnim ~= arg_0_1 then
		var_0_emotionInstance.forcedFaceAnim = arg_0_1
		var_0_emotionInstance.forcedFaceRestart = true
		-- back to the emotion group straight away, not when the looping face clip ends
		var_0_emotionInstance.forceEvaluate = arg_0_1 == nil
	end
end

local function var_0_lettersOnly(arg_0_0)
	return (string.lower(arg_0_0 or ""):gsub("[^a-z]", ""))
end

local function var_0_setCamera(arg_0_0, arg_0_1)
	-- set directly: setCameraInfo also queues the camera's idle animation
	arg_0_0.cameraInfo = VERIFY(playermodel_camera_aide[arg_0_1])
	arg_0_0.cameraName = arg_0_1
end

local function var_0_valueListItem(arg_0_0, arg_0_1, arg_0_2, arg_0_5)
	return {
		editable = true,
		editWrapAround = true,
		label = arg_0_0,
		getValue = function(arg_0_3)
			return arg_0_3[arg_0_2]
		end,
		setValue = function(arg_0_3, arg_0_4)
			arg_0_4[arg_0_2] = arg_0_3

			if arg_0_5 then
				arg_0_5(arg_0_3, arg_0_4)
			end
		end,
		editType = optionmenu_aide.EditTypes.ValueList,
		valueList = arg_0_1,
		displayType = optionmenu_aide.DisplayTypes.ValueList
	}
end

local var_0_autoFace = "auto"
local var_0_skippedFaces = {
	face_zero = true,
	face_test_02_pose_0 = true
}

-- every face clip named by the match and menu emotion groups that the menu has loaded
local function var_0_buildFaceList(arg_0_0)
	local var_0_list = {
		{
			value = var_0_autoFace,
			label = "Auto (celebration's own)"
		}
	}
	local var_0_names, var_0_seen = {}, {}

	for iter_0_0, iter_0_1 in ipairs({
		"intermediatelua.animations.emotiongroups",
		"intermediatelua.animations.emotiongroups_ui"
	}) do
		local var_0_ok, var_0_module = pcall(load, iter_0_1)

		if var_0_ok and type(var_0_module) == "table" and type(var_0_module.groups) == "table" then
			for iter_0_2, iter_0_3 in pairs(var_0_module.groups) do
				for iter_0_4 in pairs(iter_0_3.anims or {}) do
					if not var_0_seen[iter_0_4] then
						var_0_seen[iter_0_4] = true

						table.insert(var_0_names, iter_0_4)
					end
				end
			end
		end
	end

	table.sort(var_0_names)

	for iter_0_5, iter_0_6 in ipairs(var_0_names) do
		if not var_0_skippedFaces[iter_0_6] and arg_0_0 and arg_0_0:getAnimationByName(iter_0_6) then
			table.insert(var_0_list, {
				value = iter_0_6,
				label = (iter_0_6:gsub("^face_", ""):gsub("_", " "))
			})
		end
	end

	return var_0_list
end

-- every club with at least one kit (a user-created override wins over its on-disc club)
local function var_0_buildClubList(arg_0_0)
	local var_0_ids, var_0_list = {}, {}

	local function var_0_add(arg_0_1)
		if arg_0_1 and not var_0_ids[arg_0_1.id] then
			var_0_ids[arg_0_1.id] = true

			local var_0_club = arg_0_0:getClub(arg_0_1.id)

			if var_0_club and var_0_club.uniformCount > 0 then
				table.insert(var_0_list, {
					value = var_0_club.id,
					label = var_0_club.fullName or tostring(var_0_club.id)
				})
			end
		end
	end

	local var_0_userCreated = arg_0_0.userCreated

	if var_0_userCreated then
		for iter_0_0 = 0, var_0_userCreated.count - 1 do
			var_0_add(var_0_userCreated:getAtIndex(iter_0_0))
		end
	end

	for iter_0_1, iter_0_2 in arg_0_0.onDisc:iterateAll() do
		var_0_add(iter_0_2)
	end

	table.sort(var_0_list, function(arg_0_2, arg_0_3)
		return arg_0_2.label < arg_0_3.label
	end)

	return var_0_list
end

-- refills `list` in place: the Kit row keeps the same valueList table
local function var_0_fillKitList(arg_0_0, arg_0_1)
	for iter_0_0 = #arg_0_0, 1, -1 do
		arg_0_0[iter_0_0] = nil
	end

	for iter_0_1 = 1, arg_0_1 and arg_0_1.uniformCount or 0 do
		local var_0_uniform = arg_0_1:getUniform(iter_0_1)
		local var_0_label = var_0_uniform:getDisplayName(iter_0_1)

		if var_0_uniform.isHidden then
			var_0_label = var_0_label .. " (hidden)"
		end

		table.insert(arg_0_0, {
			value = iter_0_1,
			label = var_0_label
		})
	end
end

local function var_0_defaultKitIndex(arg_0_0)
	local var_0_ok, var_0_index = pcall(function()
		return arg_0_0:getDefaultUniformIndex(native.CClubUniformCategory:fromInt(0))
	end)

	if var_0_ok and type(var_0_index) == "number" and var_0_index >= 1 and var_0_index <= arg_0_0.uniformCount then
		return var_0_index
	end

	return 1
end

Class("AcademyPlayerViewCelebrationState", var_0_optionMenuState)

function AcademyPlayerViewCelebrationState.enter(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7, arg_0_8)
	arg_0_0.goBackFactory = arg_0_8
	arg_0_0.partyMember = VERIFY(arg_0_6.partyMember)
	arg_0_0.paused = false

	local var_0_clip = var_0_celebrations[1].value
	local var_0_ok, var_0_name = pcall(function()
		return arg_0_7.player.identity.fullName
	end)

	if var_0_ok and var_0_name then
		for iter_0_0, iter_0_1 in ipairs(var_0_celebrations) do
			if var_0_lettersOnly(iter_0_1.label) == var_0_lettersOnly(var_0_name) then
				var_0_clip = iter_0_1.value
			end
		end
	end

	arg_0_0.model = arg_0_5:playerModelGetPlayer(1)
	arg_0_0.clubManager = arg_0_5:getClubManager()

	local var_0_model = arg_0_0.model
	local var_0_clubManager = arg_0_0.clubManager
	local var_0_clubList = var_0_buildClubList(var_0_clubManager)
	local var_0_club = arg_0_7.club and var_0_clubManager:getClub(arg_0_7.club.id)

	if not var_0_club or var_0_club.uniformCount == 0 then
		var_0_club = var_0_clubList[1] and var_0_clubManager:getClub(var_0_clubList[1].value)
	end

	local var_0_kitList = {}

	var_0_fillKitList(var_0_kitList, var_0_club)

	arg_0_0.params = {
		clip = var_0_clip,
		face = var_0_autoFace,
		framing = var_0_framings[1].value,
		club = var_0_club and var_0_club.id,
		kit = var_0_club and var_0_defaultKitIndex(var_0_club)
	}

	var_0_setCamera(var_0_model, arg_0_0.params.framing)

	arg_0_0.appliedFraming = arg_0_0.params.framing
	arg_0_0.appliedClub = arg_0_0.params.club
	arg_0_0.appliedKit = arg_0_0.params.kit

	-- the jersey picked here is only for the preview: the player's own comes back on exit
	local var_0_characterConfig, var_0_uniformConfig = var_0_model:getVisualConfig()

	arg_0_0.savedUniform = native.CVisualConfig("team")

	arg_0_0.savedUniform:copy(var_0_uniformConfig)

	arg_0_0.savedClubIdentity = native.CClubIdentity()

	arg_0_0.savedClubIdentity:set(var_0_model.clubIdentity)

	local var_0_items = {
		var_0_valueListItem("Celebration", var_0_celebrations, "clip"),
		var_0_valueListItem("Face", var_0_buildFaceList(var_0_model:getAnimationProvider()), "face"),
		var_0_valueListItem("Framing", var_0_framings, "framing")
	}

	if #var_0_clubList > 0 then
		table.insert(var_0_items, var_0_valueListItem("Club", var_0_clubList, "club", function(arg_0_9, arg_0_10)
			local var_0_newClub = var_0_clubManager:getClub(arg_0_9)

			var_0_fillKitList(var_0_kitList, var_0_newClub)

			arg_0_10.kit = var_0_newClub and var_0_defaultKitIndex(var_0_newClub)
		end))
		table.insert(var_0_items, var_0_valueListItem("Kit", var_0_kitList, "kit"))
	end

	var_0_optionMenuState.enter(arg_0_0, arg_0_2, arg_0_3, arg_0_4, arg_0_5, var_0_items, nil, {
		backInputAllowed = true,
		noSpaceBeforePanel = true,
		itemParams = arg_0_0.params,
		titleBox = {
			left = true,
			title = "Celebrations"
		}
	})
end

function AcademyPlayerViewCelebrationState.exit(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4)
	var_0_optionMenuState.exit(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4)

	if arg_0_0.model then
		arg_0_0.model:setAnimationUpdateEnabled(true)
		var_0_setForcedFace(arg_0_0.model, nil)

		if arg_0_0.jerseyChanged then
			arg_0_0.model:setUniformConfig(arg_0_0.savedUniform, arg_0_0.savedClubIdentity)
			arg_0_0.model:refresh()
		end
	end
end

function AcademyPlayerViewCelebrationState.updateJersey(arg_0_0)
	local var_0_params = arg_0_0.params

	if var_0_params.club == arg_0_0.appliedClub and var_0_params.kit == arg_0_0.appliedKit then
		return
	end

	arg_0_0.appliedClub = var_0_params.club
	arg_0_0.appliedKit = var_0_params.kit

	local var_0_club = var_0_params.club and arg_0_0.clubManager:getClub(var_0_params.club)

	if not var_0_club or not var_0_params.kit or var_0_params.kit > var_0_club.uniformCount then
		return
	end

	arg_0_0.model:setUniformConfig(var_0_club:getUniform(var_0_params.kit).config, var_0_club.identity)
	arg_0_0.model:refresh()

	arg_0_0.jerseyChanged = true
end

function AcademyPlayerViewCelebrationState.addCustomTooltips(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	arg_0_2:addTooltip(arg_0_0.tooltipsWidget, native.InputTypes.X, arg_0_0.paused and "Resume" or "Pause", 17)
end

function AcademyPlayerViewCelebrationState.updateCelebration(arg_0_0)
	local var_0_model = arg_0_0.model
	local var_0_animation = var_0_model.playerModelAnimation

	if not var_0_animation.characterAnimator:isInitialised() then
		return
	end

	local var_0_clip = arg_0_0.params.clip
	local var_0_provider = var_0_model:getAnimationProvider()

	if not var_0_provider or not var_0_provider:getAnimationByName(var_0_clip) then
		return
	end

	local var_0_command = var_0_model:getPrimaryBodyCommand()
	local var_0_restart = not var_0_command or var_0_command.anim ~= var_0_clip or var_0_command:isFinished()

	if var_0_restart then
		-- first play, a different clip picked, the clip ended, or something queued an idle over it
		var_0_model.animName = var_0_clip

		var_0_animation:playBodyAnim(var_0_clip, {
			disableFootFallMatching = true,
			transitionFrameCount = var_0_celebrationBlendFrames
		}, true)
	end

	local var_0_face = arg_0_0.params.face

	if var_0_face == var_0_autoFace then
		var_0_face = var_0_faceByClip[var_0_clip]
	end

	if var_0_face and not var_0_provider:getAnimationByName(var_0_face) then
		var_0_face = nil
	end

	var_0_setForcedFace(var_0_model, var_0_face)

	if var_0_restart and var_0_face then
		var_0_animation.emotion.forcedFaceRestart = true
	end
end

function AcademyPlayerViewCelebrationState.update(arg_0_0, arg_0_1, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7, arg_0_8, arg_0_9)
	local var_0_partyMember = arg_0_0.partyMember
	local var_0_finished = var_0_optionMenuState.update(arg_0_0, arg_0_2, arg_0_3, arg_0_4, arg_0_5, arg_0_6, arg_0_7, var_0_partyMember:getInput())

	if var_0_finished then
		arg_0_1:changeState(arg_0_0.goBackFactory(), arg_0_2, arg_0_3, arg_0_5, arg_0_6, arg_0_8, arg_0_9, arg_0_0.__proto)

		return
	end

	if arg_0_0.params.framing ~= arg_0_0.appliedFraming then
		var_0_setCamera(arg_0_0.model, arg_0_0.params.framing)

		arg_0_0.appliedFraming = arg_0_0.params.framing
	end

	if arg_0_0.paused and (arg_0_0.params.clip ~= arg_0_0.pausedClip or arg_0_0.params.face ~= arg_0_0.pausedFace) then
		arg_0_0.paused = false

		arg_0_0.model:setAnimationUpdateEnabled(true)
	end

	if not arg_0_0.subState and arg_0_6:checkForRelease(var_0_partyMember, native.InputTypes.X) then
		arg_0_6:playSound("Select")

		arg_0_0.paused = not arg_0_0.paused
		arg_0_0.pausedClip = arg_0_0.params.clip
		arg_0_0.pausedFace = arg_0_0.params.face

		arg_0_0.model:setAnimationUpdateEnabled(not arg_0_0.paused)
	end

	arg_0_0:updateJersey()
	arg_0_0:updateCelebration()
end

local var_0_celebrationTile = {
	image = "academy/player/appearance",
	colSize = 1,
	colStart = 1,
	rowSize = 1,
	rowStart = 4,
	title = "Celebrations",
	description = "Play a Melbourne Storm promo try celebration on this player, looped.",
	stateFactory = AcademyPlayerViewCelebrationState
}

local function var_0_1(arg_1_0)
	return (arg_1_0.player or arg_1_0.coach or arg_1_0.referee).sharing.isOnSharingServer
end

function CreateTiles(arg_2_0, arg_2_1, arg_2_2)
	local function var_2_0(arg_3_0)
		local var_3_0 = arg_2_1.debugHook

		if var_3_0 and var_3_0.isArtist then
			return false
		end

		if not arg_3_0.canEdit or arg_3_0.isTier1 then
			return true
		end

		return false
	end

	local var_2_1 = {
		colSize = 1,
		image = "academy/player/appearance",
		colStart = 1,
		rowStart = 1,
		rowSize = 2,
		title = native.Localise("Appearance"),
		description = native.Localise("AppearanceDescription"),
		stateFactory = academy_player_viewstate_appearance_state.AcademyPlayerViewAppearanceState,
		lockedGetFn = var_2_0,
		lockedReason = native.Localise("Tier1Likeness")
	}

	if not arg_2_2 or not arg_2_2.isTier1 then
		var_2_1.additionalTooltips = {
			{
				behaveSameAsStandardSelection = true,
				inputType = native.InputTypes.Y,
				label = native.Localise("CopyAppearanceOfAnotherPlayer"),
				stateFactory = academy_player_viewstate_copyappearance_state.AcademyPlayerCopyAppearanceState
			}
		}
	end

	return {
		{
			image = "academy/player/identity",
			colSize = 1,
			colStart = 2,
			rowSize = 1,
			rowStart = 1,
			title = native.Localise("Identity"),
			description = native.Localise("IdentityDescription"),
			stateFactory = player_viewstate_identity_state.PlayerViewIdentityState
		},
		var_2_1,
		{
			image = "academy/player/skills",
			colSize = 1,
			colStart = 2,
			rowSize = 1,
			rowStart = 2,
			title = native.Localise("Skills"),
			description = native.Localise("AttributesDescription"),
			stateFactory = player_viewstate_attributes_state.PlayerViewAttributesState
		},
		{
			image = "academy/player/team",
			colSize = 1,
			colStart = 2,
			rowSize = 1,
			rowStart = 3,
			title = native.Localise("Team"),
			description = native.Localise("TeamEditDescription"),
			stateFactory = academy_player_createcustom_clubselect_state.AcademyPlayerCreateCustomClubSelectState
		},
		{
			image = "academy/player/sharing",
			colSize = 1,
			colStart = 1,
			rowSize = 1,
			rowStart = 3,
			title = native.Localise("Sharing"),
			description = native.Localise("SharingDescription"),
			stateFactory = player_viewstate_sharing_state.PlayerViewSharingState
		},
		var_0_celebrationTile
	}
end

ReadOnlyTiles = {
	{
		image = "academy/player/identity",
		colSize = 1,
		colStart = 1,
		rowSize = 1,
		rowStart = 1,
		title = native.Localise("Identity"),
		description = native.Localise("IdentityDescription"),
		stateFactory = player_viewstate_identity_state.PlayerViewIdentityState
	},
	{
		image = "academy/player/sharing",
		colSize = 1,
		colStart = 1,
		rowSize = 1,
		rowStart = 2,
		title = native.Localise("Sharing"),
		description = native.Localise("SharingDescription"),
		stateFactory = player_viewstate_sharing_state.PlayerViewSharingState
	},
	{
		colSize = 1,
		colStart = 2,
		rowStart = 1,
		image = "academy/player/attributes",
		rowSize = 1,
		title = native.Localise("Skills"),
		locked = var_0_0,
		description = native.Localise("AttributesDescription"),
		stateFactory = player_viewstate_attributes_state.PlayerViewAttributesState
	},
	{
		image = "academy/player/statistics",
		colSize = 1,
		colStart = 2,
		rowSize = 1,
		rowStart = 2,
		title = native.Localise("Statistics"),
		description = native.Localise("StatisticsEditDescription"),
		stateFactory = player_viewstate_statistics_state.PlayerViewStatisticsState
	},
	var_0_celebrationTile
}
CommunityTiles = {
	{
		colSize = 1,
		rowStart = 1,
		colStart = 1,
		image = "academy/community/search/players/rate",
		rowSize = 1,
		title = native.Localise("Rate"),
		description = native.Localise("RateDescription"),
		lockedGetFn = function(arg_4_0)
			return not var_0_1(arg_4_0)
		end,
		subStateFactory = academy_communitystate_playerstate_viewstate_rate_substate.AcademyCommunityPlayerRateSubState
	},
	{
		colSize = 1,
		rowStart = 2,
		colStart = 1,
		image = "academy/community/search/players/download",
		rowSize = 1,
		title = native.Localise("Download"),
		description = native.Localise("DownloadDescription"),
		lockedGetFn = function(arg_5_0)
			return not var_0_1(arg_5_0)
		end,
		subStateFactory = academy_communitystate_playerstate_download_substate.AcademyCommunityPlayerDownloadSubState
	},
	{
		colSize = 1,
		rowStart = 3,
		colStart = 1,
		image = "academy/community/search/players/report",
		rowSize = 1,
		title = native.Localise("Report"),
		description = native.Localise("ReportDescription"),
		lockedGetFn = function(arg_6_0)
			return not var_0_1(arg_6_0)
		end,
		subStateFactory = academy_communitystate_playerstate_viewstate_report_substate.AcademyCommunityPlayerReportSubState
	},
	{
		image = "academy/community/search/players/identity",
		colSize = 1,
		colStart = 2,
		rowSize = 1,
		rowStart = 1,
		title = native.Localise("Identity"),
		description = native.Localise("IdentityCommunityDescription"),
		stateFactory = player_viewstate_identity_state.PlayerViewIdentityState
	},
	{
		image = "academy/community/search/players/sharing",
		colSize = 1,
		colStart = 2,
		rowSize = 1,
		rowStart = 2,
		title = native.Localise("Sharing"),
		description = native.Localise("SharingCommunityDescription"),
		stateFactory = player_viewstate_sharing_state.PlayerViewSharingState
	},
	{
		image = "academy/community/search/players/attributes",
		colSize = 1,
		colStart = 2,
		rowSize = 1,
		rowStart = 3,
		title = native.Localise("Skills"),
		description = native.Localise("AttributesCommunityDescription"),
		stateFactory = player_viewstate_attributes_state.PlayerViewAttributesState
	}
}
