import("tools.common.timer")
import("script-config.design.sound.soundmap_rtpc")
import("script-config.design.sound.soundmap_banks")
import("script-config.design.sound.soundmap_states")
import("script-config.design.sound.soundmap_switches")

local var_0_0 = soundmap_states.States
local var_0_1 = soundmap_switches.Switches
local var_0_2 = var_0_0.Frontend_Music_States
local var_0_3 = var_0_0.HalfTime_Music_State
local var_0_4 = 0.5
local var_0_5 = 2
local var_0_6 = 1
local var_0_7 = 3
local var_0_8 = 0.5
local var_0_9
local var_0_10
local var_0_11 = native.getEnvironment():argExists("debugSound")
local var_0_12 = native.getEnvironment():argExists("debugLoudspeakerMusic")
local var_0_13 = native.ESide.Home:toInt()
local var_0_14 = native.ESide.Away:toInt()
local var_0_15 = native.ESide.None:toInt()
local var_0_16 = "IngameMusic"

-- team-try-songs: a club's own try song replaces the stock try music.
-- Each song is its own Wwise bank + event "try_song_<club icon>", added by
-- tools/add_sound_bank.py. Who gets their song:
--   NRL finals / Grand Final -> whichever team scores
--   any other match          -> only the home team
-- The song is queued like the stock Loudspeaker_Music (same delay, same
-- "IngameMusic" tag), so the stock stop points fade it out too.

-- Club icons that have a try_song_<icon> bank installed. Only list installed
-- banks: loading a missing bank is a native crash that pcall can't catch.
local TrySongs = {
	nrl_broncos = true,
	nrl_roosters = true
}

-- Logs to trysongs_debug.txt in the game folder.
local TrySongsDebug = false

-- bunker-broadcast-decision: a bunker TRY gets the try music (or the club's song), starting
-- this long after VideoRefereeDecisionEvent: just after the try whistle (3.25 s,
-- soundlistener_referee.lua). Stock bunker tries have no music.
local BunkerTryMusicDelay = 3.6

local function trySongsLog(arg_text)
	if not TrySongsDebug then
		return
	end

	pcall(function()
		local file = io.open("trysongs_debug.txt", "a")

		if file then
			file:write(tostring(arg_text) .. "\n")
			file:close()
		end
	end)
end

local function trySongsClubIcon(arg_club)
	local ok, icon = pcall(function()
		local decalIdOrIcon = arg_club.decalIdOrIcon or arg_club.identity.decalIdOrIcon

		return decalIdOrIcon.icon
	end)

	if ok and icon ~= nil and tostring(icon) ~= "" then
		return tostring(icon)
	end
end

-- NRL finals series or Grand Final (career/competition fixtures, or a
-- Grand Final played from the casual menu).
local function trySongsIsNRLFinals(arg_matchInData)
	local ok, result = pcall(function()
		local season = arg_matchInData.stateOfTheSeason or {}
		local cutsceneInfo = arg_matchInData.cutsceneInfo or {}
		local finals = season.isFinal or season.isGrandFinal or cutsceneInfo.playGFIntroCutscene

		if not finals then
			return false
		end

		if season.competitionId ~= nil then
			return season.competitionId == native.CareerCompetitionIdEnum.League_NRL
		end

		return arg_matchInData.matchType.rules ~= native.MatchSettingsRules.superleague
	end)

	return ok and result or false
end

-- {[side int] = song event} for the clubs in this match that get a song.
local function trySongsForMatch(arg_universe)
	local songs = {}
	local matchInData = arg_universe.matchInData
	local finals = trySongsIsNRLFinals(matchInData)

	for side, sideInt in pairs({
		home = var_0_13,
		away = var_0_14
	}) do
		local icon = trySongsClubIcon(matchInData[side])

		if not icon then
			icon = trySongsClubIcon(arg_universe[side].matchClub)
		end

		if icon and TrySongs[icon] and (finals or sideInt == var_0_13) then
			songs[sideInt] = "try_song_" .. icon
		end

		trySongsLog(side .. ": icon=" .. tostring(icon) .. " finals=" .. tostring(finals) .. " song=" .. tostring(songs[sideInt]))
	end

	return songs
end

Class("SoundListenerIngameMusic", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6)
	arg_1_0.enabled = true

	if not arg_1_0.enabled then
		return
	end

	arg_1_0.soundSystem = arg_1_1
	arg_1_0.soundManager = arg_1_5
	arg_1_0.trainingMode = arg_1_4.trainingMode
	arg_1_0.musicPlaying = false

	local var_1_0 = {
		home = "homeMusic",
		away = "awayMusic"
	}

	for iter_1_0, iter_1_1 in pairs(var_1_0) do
		arg_1_5:registerGameObject(iter_1_1)
	end

	arg_1_0.musicSoundObjects = var_1_0

	local var_1_1 = var_0_1.sfxSwitchTeamCountry
	local var_1_2 = var_1_1.switchGroup
	local var_1_3 = var_1_1.switchNames
	local var_1_4 = var_1_3.noCountry
	local var_1_5 = arg_1_3.home.matchClub
	local var_1_6 = arg_1_3.away.matchClub
	local var_1_7 = var_1_5 and var_1_5.clubAffiliation
	local var_1_8 = var_1_6 and var_1_6.clubAffiliation
	local var_1_9 = var_1_7 and var_1_3[var_1_7] or var_1_4
	local var_1_10 = var_1_8 and var_1_3[var_1_8] or var_1_4

	arg_1_1:prepareSwitch(var_1_1, var_1_9)
	arg_1_1:prepareSwitch(var_1_1, var_1_10)
	arg_1_5:setSwitchValue(var_1_2, var_1_9, var_1_0.home)
	arg_1_5:setSwitchValue(var_1_2, var_1_10, var_1_0.away)

	arg_1_0.anthemAvailable = var_1_9 ~= var_1_4 and var_1_10 ~= var_1_4
	arg_1_0.sameAnthem = var_1_9 == var_1_10

	table.insert(arg_1_2, soundmap_banks.Banks.Loudspeaker_Global)

	-- team-try-songs: the stock bank loader loads these with the match and
	-- unloads them after it.
	local ok, songs = pcall(trySongsForMatch, arg_1_3)

	arg_1_0.trySongs = ok and songs or {}

	if not ok then
		trySongsLog("match setup failed: " .. tostring(songs))
	end

	for _, song in pairs(arg_1_0.trySongs) do
		table.insert(arg_1_2, {
			name = song,
			bankType = soundmap_banks.BankTypes.Complete,
			sounds = {
				[song] = song
			}
		})
	end

	arg_1_0:initTimers()
end)

function SoundListenerIngameMusic.unload(arg_2_0)
	if not arg_2_0.enabled then
		return
	end

	local var_2_0 = arg_2_0.soundManager

	if arg_2_0.musicPlaying and var_2_0 then
		var_2_0:stopMusic()
		arg_2_0:setMusicState("RegularPlay")
	end
end

function SoundListenerIngameMusic.postSoundSystemInit(arg_3_0)
	if not arg_3_0.enabled then
		return
	end

	arg_3_0.soundManager:setStateValue(var_0_3.stateGroup, var_0_3.stateNames.Loudspeaker)
end

function SoundListenerIngameMusic.registerWithMatchSim(arg_4_0, arg_4_1)
	if not arg_4_0.enabled then
		return
	end

	local var_4_0 = arg_4_0.soundSystem

	var_4_0:registerSoundOnlyEvents(arg_4_0, {
		PlayAwayThemeEvent = arg_4_0.onPlayAwayThemeEvent,
		PlayHomeThemeEvent = arg_4_0.onPlayHomeThemeEvent,
		PlayNationalAnthemEvent = arg_4_0.onPlayNationalAnthemEvent,
		StopAwayThemeEvent = arg_4_0.onStopAwayThemeEvent,
		StopHomeThemeEvent = arg_4_0.onStopHomeThemeEvent,
		StopNationalAnthemEvent = arg_4_0.onStopNationalAnthemEvent,
		TrainingStartEvent = arg_4_0.onTrainingStartEvent,
		-- bunker-broadcast-decision
		VideoRefereeDecisionEvent = arg_4_0.onVideoRefereeDecisionEvent
	})
	var_4_0:registerSolidEvents(arg_4_0, arg_4_1, {
		BreakInPlayEvent = arg_4_0.onBreakInPlayEvent,
		DisposalEvent = arg_4_0.onDisposalEvent,
		FieldGoalSuccessEvent = arg_4_0.onFieldGoalSuccessEvent,
		KickoffSetupEvent = arg_4_0.onKickoffSetupEvent,
		PositionBallAndTeeEvent = arg_4_0.onPositionBallAndTeeEvent,
		TryScoredEvent = arg_4_0.onTryScoredEvent
	})
end

function SoundListenerIngameMusic.initTimers(arg_5_0)
	local var_5_0 = {}

	arg_5_0.timers = var_5_0
	var_5_0.startCelebrationMusicTimer = {
		timer = timer.Timer(var_0_4),
		expireFn = function()
			-- team-try-songs: the club's song instead of the stock music. No
			-- crowd clap-along, it wouldn't be in time with the song.
			local trySong = arg_5_0.pendingTrySong

			arg_5_0.pendingTrySong = nil

			if trySong then
				var_0_9(arg_5_0, trySong, {
					wwiseEvent = trySong
				})
				trySongsLog("play " .. trySong)

				return
			end

			var_0_9(arg_5_0, "Loudspeaker_Music")

			local var_6_0 = soundmap_rtpc.inGameRTPCs.crowdClapAlongVol

			arg_5_0.soundManager:setGlobalRTPC(var_6_0.rtpc, var_6_0.onValue)
		end
	}
end

function SoundListenerIngameMusic.resetTimers(arg_7_0)
	for iter_7_0, iter_7_1 in pairs(arg_7_0.timers) do
		iter_7_1.timer:stop()
	end
end

function SoundListenerIngameMusic.updateTimers(arg_8_0, arg_8_1, arg_8_2, arg_8_3, arg_8_4, arg_8_5, arg_8_6)
	for iter_8_0, iter_8_1 in pairs(arg_8_0.timers) do
		local var_8_0 = iter_8_1.timer
		local var_8_1 = iter_8_1.expireFn

		if var_8_0:isActive() and var_8_0:update(arg_8_5) and var_8_1 then
			var_8_1()
		end
	end
end

function SoundListenerIngameMusic.enterInteractiveReplay(arg_9_0)
	if not arg_9_0.enabled then
		return
	end

	stopAllLoudspeakerMusic(arg_9_0)
end

function SoundListenerIngameMusic.reset(arg_10_0)
	if not arg_10_0.enabled then
		return
	end
end

function SoundListenerIngameMusic.update(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6)
	if not arg_11_0.enabled then
		return
	end

	arg_11_0:updateTimers(arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6)
end

function SoundListenerIngameMusic.startCelebrationMusic(arg_12_0, arg_12_1, arg_12_2)
	if not arg_12_0.enabled or arg_12_0.trainingMode then
		return
	end

	-- team-try-songs: song to play instead of the stock music (nil = stock).
	arg_12_0.pendingTrySong = arg_12_2

	local var_12_0 = arg_12_0.timers.startCelebrationMusicTimer.timer

	var_12_0.capTime = arg_12_1 or var_0_4

	var_12_0:resetAndStart()
end

function SoundListenerIngameMusic.stopCelebrationMusic(arg_13_0)
	if not arg_13_0.enabled then
		return
	end

	stopAllLoudspeakerMusic(arg_13_0)
	arg_13_0.timers.startCelebrationMusicTimer.timer:stop()

	local var_13_0 = soundmap_rtpc.inGameRTPCs.crowdClapAlongVol

	arg_13_0.soundManager:setGlobalRTPC(var_13_0.rtpc, var_13_0.startingValue)
end

function SoundListenerIngameMusic.startMusic(arg_14_0)
	local var_14_0 = arg_14_0.soundManager

	if arg_14_0.trainingMode and var_14_0 then
		arg_14_0:setMusicState("Loudspeaker")
		var_14_0:startMusic()

		arg_14_0.musicPlaying = true
	end
end

function SoundListenerIngameMusic.setMusicState(arg_15_0, arg_15_1)
	local var_15_0 = arg_15_0.soundManager

	if var_15_0 then
		local var_15_1 = VERIFY(var_0_2.stateNames[arg_15_1])

		var_15_0:setStateValue(var_0_2.stateGroup, var_15_1)
	end
end

function SoundListenerIngameMusic.onPlayAwayThemeEvent(arg_16_0, arg_16_1, arg_16_2, arg_16_3, arg_16_4, arg_16_5, arg_16_6)
	if not arg_16_0.enabled then
		return
	end

	var_0_9(arg_16_0, "Walk_On_Music")
end

function SoundListenerIngameMusic.onPlayHomeThemeEvent(arg_17_0, arg_17_1, arg_17_2, arg_17_3, arg_17_4, arg_17_5, arg_17_6)
	if not arg_17_0.enabled then
		return
	end

	var_0_9(arg_17_0, "Walk_On_Music")
end

function SoundListenerIngameMusic.onPlayNationalAnthemEvent(arg_18_0, arg_18_1, arg_18_2, arg_18_3, arg_18_4, arg_18_5, arg_18_6)
	if not arg_18_0.enabled then
		return
	end

	local var_18_0

	if arg_18_0.sameAnthem and not arg_18_1.checkSameAnthem then
		var_18_0 = "sfxMusicPaAnthem"
	elseif not arg_18_0.sameAnthem then
		var_18_0 = "sfxMusicPaAnthem15sec"
	end

	if var_18_0 then
		stopAllLoudspeakerMusic(arg_18_0)

		local var_18_1 = arg_18_0.musicSoundObjects
		local var_18_2 = arg_18_1.side == var_0_14 and var_18_1.away or var_18_1.home

		var_0_9(arg_18_0, var_18_0, {
			soundObject = var_18_2
		})
	end
end

function SoundListenerIngameMusic.onStopAwayThemeEvent(arg_19_0, arg_19_1, arg_19_2, arg_19_3, arg_19_4, arg_19_5, arg_19_6)
	if not arg_19_0.enabled then
		return
	end

	var_0_10(arg_19_0, "Walk_On_Music", {
		fadeTime = var_0_8
	})
end

function SoundListenerIngameMusic.onStopHomeThemeEvent(arg_20_0, arg_20_1, arg_20_2, arg_20_3, arg_20_4, arg_20_5, arg_20_6)
	if not arg_20_0.enabled then
		return
	end

	var_0_10(arg_20_0, "Walk_On_Music", {
		fadeTime = var_0_8
	})
end

function SoundListenerIngameMusic.onStopNationalAnthemEvent(arg_21_0, arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5, arg_21_6)
	if not arg_21_0.enabled then
		return
	end

	if arg_21_0.sameAnthem and not arg_21_1.checkSameAnthem then
		var_0_10(arg_21_0, "sfxMusicPaAnthem", {
			fadeTime = var_0_8
		})
	elseif not arg_21_0.sameAnthem then
		var_0_10(arg_21_0, "sfxMusicPaAnthem15sec", {
			fadeTime = var_0_8
		})
	end
end

function SoundListenerIngameMusic.onTrainingStartEvent(arg_22_0, arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5, arg_22_6)
	if not arg_22_0.enabled then
		return
	end

	if not arg_22_0.musicPlaying then
		arg_22_0:startMusic()
	end
end

function SoundListenerIngameMusic.onBreakInPlayEvent(arg_23_0, arg_23_1, arg_23_2, arg_23_3, arg_23_4, arg_23_5, arg_23_6, arg_23_7, arg_23_8, arg_23_9)
	if not arg_23_0.enabled then
		return
	end

	arg_23_0.soundManager:setStateValue(var_0_3.stateGroup, var_0_3.stateNames.TransitionToFrontEnd)
end

function SoundListenerIngameMusic.onDisposalEvent(arg_24_0, arg_24_1, arg_24_2, arg_24_3, arg_24_4, arg_24_5, arg_24_6, arg_24_7, arg_24_8, arg_24_9)
	if var_0_12 then
		arg_24_0:startCelebrationMusic(1)
	end
end

function SoundListenerIngameMusic.onFieldGoalSuccessEvent(arg_25_0, arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5, arg_25_6, arg_25_7, arg_25_8, arg_25_9)
	if not arg_25_0.enabled then
		return
	end

	arg_25_0:startCelebrationMusic(var_0_6)
end

function SoundListenerIngameMusic.onKickoffSetupEvent(arg_26_0, arg_26_1, arg_26_2, arg_26_3, arg_26_4, arg_26_5, arg_26_6, arg_26_7, arg_26_8, arg_26_9)
	if not arg_26_0.enabled then
		return
	end

	stopAllLoudspeakerMusic(arg_26_0)
end

function SoundListenerIngameMusic.onPositionBallAndTeeEvent(arg_27_0, arg_27_1, arg_27_2, arg_27_3, arg_27_4, arg_27_5, arg_27_6, arg_27_7, arg_27_8, arg_27_9)
	if not arg_27_0.enabled then
		return
	end

	stopAllLoudspeakerMusic(arg_27_0)
end

function SoundListenerIngameMusic.onTryScoredEvent(arg_28_0, arg_28_1, arg_28_2, arg_28_3, arg_28_4, arg_28_5, arg_28_6, arg_28_7, arg_28_8, arg_28_9)
	if not arg_28_0.enabled then
		return
	end

	-- bunker-overturned-try: a provisional try gets the try music too.
	if not arg_28_1.unsuccessfulAttempt and not arg_28_1.videoRefereeRequired or arg_28_1.provisionalTry then
		-- team-try-songs: the scoring club's song, if it gets one this match.
		arg_28_0:startCelebrationMusic(var_0_5, arg_28_0.trySongs[arg_28_1.scoringSide])
	end
end

-- bunker-broadcast-decision: music for a TRY given by the bunker (the decision event only
-- carries bunkerBroadcast when that presentation is running).
function SoundListenerIngameMusic.onVideoRefereeDecisionEvent(arg_b_0, arg_b_1, arg_b_2, arg_b_3, arg_b_4, arg_b_5, arg_b_6)
	if not arg_b_0.enabled or not arg_b_1.bunkerBroadcast or not arg_b_1.isTry then
		return
	end

	arg_b_0:startCelebrationMusic(BunkerTryMusicDelay, arg_b_1.scoringSide and arg_b_0.trySongs[arg_b_1.scoringSide])
end

function var_0_9(arg_29_0, arg_29_1, arg_29_2)
	return arg_29_0.soundSystem:queueEvent(arg_29_1, arg_29_2, var_0_16)
end

function var_0_10(arg_30_0, arg_30_1, arg_30_2)
	if arg_30_1 then
		local var_30_0 = arg_30_2.fadeTime or 1

		arg_30_0.soundSystem:stopEvents({
			soundKey = arg_30_1,
			fadeTime = var_30_0
		})
	end
end

function stopAllLoudspeakerMusic(arg_31_0, arg_31_1)
	arg_31_0.soundSystem:stopEvents({
		tags = {
			var_0_16
		},
		fadeTime = arg_31_1 or var_0_7
	})

	local var_31_0 = soundmap_rtpc.inGameRTPCs.crowdClapAlongVol

	arg_31_0.soundManager:setGlobalRTPC(var_31_0.rtpc, var_31_0.startingValue)
end
