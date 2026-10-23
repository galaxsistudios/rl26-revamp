import("base.transition.logotransition_hud")
import("sim.hud.blackscreen_hud")
import("sim.hud.connectivity_hud")
import("sim.hud.countdowntimer_hud")
import("sim.hud.drill_hud")
import("sim.hud.freeroaminteractivereplay_hud")
import("sim.hud.gameplaynotification_hud")
import("sim.hud.gameplayscore_hud")
import("sim.hud.gamepadbuttonfacehints_hud_left")
import("sim.hud.gamepadbuttonfacehints_hud_right")
import("sim.hud.introcameo_hud")
import("sim.hud.matchreportingalert_hud")
import("sim.hud.penaltyselect_hud")
import("sim.hud.playercontrols_hud")
import("sim.hud.playerindicators_hud")
import("sim.hud.playerinfo_hud")
import("sim.hud.playermarkers")
import("sim.hud.playeroffscreen_hud")
import("sim.hud.playerstatistics_hud")
import("sim.hud.playgo_hud")
import("sim.hud.kickingpowerhud")
import("sim.hud.possessionindicator_hud")
import("sim.hud.remoteplayer_hud")
import("sim.hud.replay_hud")
import("sim.hud.scorernotification_hud")
import("sim.hud.substitution_hud")
import("sim.hud.tactics_hud")
import("sim.hud.tips_hud")
import("sim.hud.tutorial_hud")
import("sim.hud.videoref_hud")
import("sim.hud.captainschallenge_hud")
import("sim.hud.playernamefield_hud")

function register(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5)
	local var_1_0 = arg_1_3.services
	local var_1_1 = arg_1_3.gamestate
	local var_1_2 = arg_1_3.gamers
	local var_1_3 = arg_1_3.scene

	local function var_1_4(arg_2_0, arg_2_1)
		arg_1_0:registerWithHud(arg_2_0(arg_1_1, arg_1_4, arg_1_5, var_1_0, var_1_1, var_1_2, arg_1_0, var_1_3), arg_2_1)
	end

	if arg_1_4.playGo then
		var_1_4(playgo_hud.PlayGoHud, "playgoHud")
		var_1_4(logotransition_hud.LogoTransitionHud, "logotransition")
		var_1_4(kickingpowerhud.KickingPowerHud, "KickingPowerHud")
		var_1_4(gamepadbuttonfacehints_hud_left.GamepadButtonFaceHintsLeft, "gamepadButtonFaceHintsLeft")
		var_1_4(gamepadbuttonfacehints_hud_right.GamepadButtonFaceHintsRight, "gamepadButtonFaceHintsRight")

		return
	end

	-- gf-intro-effects: outside the publicfacing gate below (retail is
	-- publicfacing) and first, so the smoke renders under the other HUD elements.
	var_1_4(blackscreen_hud.GFSmokeHud, "gfsmokehud")
	var_1_4(blackscreen_hud.GFIntroMusicHud, "gfintromusichud")
	var_1_4(blackscreen_hud.GFCrowdLightsHud, "gfcrowdlightshud")
	var_1_4(tutorial_hud.TutorialHud, "tutorialhud")

	if not native.precert and not native.publicfacing then
		var_1_4(tips_hud.TipsHud, "tips")

		if native.sportType == "lacrosse" then
			var_1_4(playercontrols_hud.PlayerControlsHud, "playerControls")
		end

		var_1_4(scorernotification_hud.ScorerNotificationHud, "scorerNotificationHud")
		var_1_4(introcameo_hud.IntroCameoHud, "introcameo")
		var_1_4(blackscreen_hud.BlackScreenHud, "blackscreenhud")
		var_1_4(drill_hud.DrillHud, "drillhud")
		var_1_4(connectivity_hud.ConnectivityHud, "connectivity_hud")
	end

	var_1_4(captainschallenge_hud.CaptainsChallengeHud, "CaptainsChallengeHud")
	var_1_4(freeroaminteractivereplay_hud.FreeRoamInteractiveReplayHud, "freeroaminteractivereplay")
	var_1_4(replay_hud.ReplayHud, "replay")
	var_1_4(playermarkers.PlayerMarkers, "playermarkers")
	var_1_4(gameplayscore_hud.GameplayScoreHud, "gameplayscore")
	var_1_4(matchreportingalert_hud.MatchReportAlertHud, "matchReportingAlert")
	var_1_4(playerindicators_hud.PlayerIndicatorsHud, "playerindicators")
	var_1_4(kickingpowerhud.KickingPowerHud, "KickingPowerHud")
	var_1_4(possessionindicator_hud.PossessionIndicatorHud, "possessionindicator")
	var_1_4(playeroffscreen_hud.PlayerOffscreenHud, "playeroffscreenarrows")
	var_1_4(playerinfo_hud.PlayerInfoHud, "playerinfo")
	var_1_4(playerstatistics_hud.PlayerStatisticsHud, "playerStatisticsHud")
	var_1_4(tactics_hud.TacticsHud, "tactics")
	var_1_4(substitution_hud.SubstitutionHud, "substitutions")
	var_1_4(countdowntimer_hud.CountDownTimerHud, "countdowntimer")
	var_1_4(logotransition_hud.LogoTransitionHud, "logotransition")
	var_1_4(penaltyselect_hud.PenaltySelectHud, "penaltySelect")
	var_1_4(videoref_hud.VideoRefHud, "videoRef")
	var_1_4(gameplaynotification_hud.GameplayNotificationHud, "notification")
	var_1_4(remoteplayer_hud.RemotePlayerHud, "remoteplayer")
	var_1_4(gamepadbuttonfacehints_hud_left.GamepadButtonFaceHintsLeft, "gamepadButtonFaceHintsLeft")
	var_1_4(gamepadbuttonfacehints_hud_right.GamepadButtonFaceHintsRight, "gamepadButtonFaceHintsRight")
	var_1_4(playernamefield_hud.PlayerNameFieldHud, "playernamefieldhud")
end
