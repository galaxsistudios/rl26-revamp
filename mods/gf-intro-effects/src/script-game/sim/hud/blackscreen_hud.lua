Class("BlackScreenHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	local var_1_0 = arg_1_1:getNetworkService():getSessionController()
	local var_1_1 = native.UIWidgetArea(arg_1_1)
	local var_1_2 = native.UIWidgetQuad(arg_1_1)

	var_1_2.colour = native.SkinColours.FullBlack
	var_1_2.alpha = 1

	var_1_2:setWidth(1, 0)
	var_1_2:setHeight(1, 0)
	var_1_1:addChild(var_1_2)

	arg_1_0.area = var_1_1
	arg_1_0.enabled = false
	arg_1_0.voiceController = var_1_0:getSessionVoiceController()

	arg_1_7.featureStack:register("blackscreenhud", arg_1_0, function(arg_2_0)
		arg_1_0:show()
	end, function()
		arg_1_0:hide()
	end)
end)

function BlackScreenHud.registerWithMatchSim(arg_4_0, arg_4_1)
	return
end

function BlackScreenHud.dispose(arg_5_0, arg_5_1)
	arg_5_0.area:dispose()
end

function BlackScreenHud.update(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11, arg_6_12)
	arg_6_0.area:update(arg_6_8)
end

function BlackScreenHud.render(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
	if arg_7_0.enabled then
		arg_7_0.area:doRender(arg_7_1, arg_7_3)
	end
end

function BlackScreenHud.show(arg_8_0)
	arg_8_0.enabled = true

	arg_8_0.voiceController:muteForLoading()
end

function BlackScreenHud.hide(arg_9_0)
	if arg_9_0.enabled then
		arg_9_0.voiceController:unmuteForLoading()
	end

	arg_9_0.enabled = false
end

-- gf-intro-effects: post-fireworks haze over every outdoor shot of the Grand
-- Final intro (armed by the stadium wide shot; off in the locker-room and
-- corridor shots, and once the intro's cutscenes end). Three layers of one screen-blend smoke texture (premultiplied
-- white, alpha = brightness - see tools/add_texture.py --screen) drift at
-- different speeds and sizes for parallax; the nearest grows fastest, as if
-- the camera pushes through, and thins first. Each shot fades in, starts
-- thick, then settles to a sustained haze for as long as the shot lasts. Lives here because build.py
-- can't add new files to the script bundle; registered in hud_registration.

local GFSmokeTexture = "ui/textures/mods/gf_smoke.texture"
local GFSmokeCutscene = "gf_stadium_wide_cam01"

-- The texture is square; layer widths assume a 16:9 screen. Every layer must
-- stay wider than the screen for the whole shot, drift included:
-- (size / aspect - 1) / 2 > |driftX| * 15s, or its edge comes into view.
local GFSmokeScreenAspect = 16 / 9

-- Per layer, far to near. size: square side as a multiple of screen height;
-- grow: size added per second; x/y: start centre (screen fractions);
-- driftX/driftY: screen fractions per second; alpha: peak opacity;
-- fadeStart/fadeEnd: seconds into the shot the layer thins from alpha down to
-- alpha * sustain, which it then holds.
local GFSmokeLayers = {
	{
		size = 2.3,
		grow = 0.02,
		x = 0.5,
		y = 0.5,
		driftX = 0.006,
		driftY = -0.002,
		alpha = 0.55,
		sustain = 0.6,
		fadeStart = 1.5,
		fadeEnd = 11
	},
	{
		size = 2.7,
		grow = 0.05,
		x = 0.44,
		y = 0.56,
		driftX = -0.012,
		driftY = -0.004,
		alpha = 0.45,
		sustain = 0.45,
		fadeStart = 1,
		fadeEnd = 8
	},
	{
		size = 3.2,
		grow = 0.14,
		x = 0.57,
		y = 0.47,
		driftX = 0.02,
		driftY = 0.006,
		alpha = 0.35,
		sustain = 0.3,
		fadeStart = 0.3,
		fadeEnd = 5
	}
}

-- Seconds for the smoke to fade in at the start of each outdoor shot.
local GFSmokeShotFadeIn = 0.5

-- Cutscenes that are indoors (no smoke): the locker rooms and the run-out corridor.
local GFSmokeIndoor = {
	"lockers",
	"corridor"
}

local function gfSmokeSmoothstep(arg_edge0, arg_edge1, arg_x)
	local t = math.min(math.max((arg_x - arg_edge0) / (arg_edge1 - arg_edge0), 0), 1)

	return t * t * (3 - 2 * t)
end

-- Debug: GFSmokeDebug writes gfsmoke_debug.txt (smoke AND intro music events);
-- GFSmokeDebugStatusSquare adds a status square (top-left). Log file:
-- gfsmoke_debug.txt (game folder, else Saved Games\Rugby League 26) when the
-- Lua io library is available. Square: white = running, no wide shot; light
-- blue = wide shot active; yellow = an error. GFSmokeDebugAnyCutscene shows
-- the smoke during EVERY cutscene, to separate "doesn't render" from "name
-- didn't match".
local GFSmokeDebug = true
local GFSmokeDebugStatusSquare = false
local GFSmokeDebugAnyCutscene = false

local gfSmokeLogFile
local gfSmokeLogTried = false

local function gfSmokeLog(arg_text)
	if not GFSmokeDebug then
		return
	end

	pcall(function()
		if not gfSmokeLogTried then
			gfSmokeLogTried = true

			if io and io.open then
				gfSmokeLogFile = io.open("gfsmoke_debug.txt", "a")

				if not gfSmokeLogFile and os and os.getenv and os.getenv("USERPROFILE") then
					gfSmokeLogFile = io.open(os.getenv("USERPROFILE") .. "/Saved Games/Rugby League 26/gfsmoke_debug.txt", "a")
				end
			end
		end

		if gfSmokeLogFile then
			gfSmokeLogFile:write(tostring(arg_text) .. "\n")
			gfSmokeLogFile:flush()
		end
	end)
end

Class("GFSmokeHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	arg_1_0.hud = arg_1_7
	arg_1_0.engine = arg_1_1
	arg_1_0.enabled = false
	arg_1_0.failed = false
	arg_1_0.layers = {}
	arg_1_0.updates = 0
	arg_1_0.renders = 0
	arg_1_0.heartbeat = 0

	gfSmokeLog("---- GFSmokeHud created; io=" .. tostring(io ~= nil) .. " os=" .. tostring(os ~= nil))

	local ok, err = pcall(function()
		local area = native.UIWidgetArea(arg_1_1)

		gfSmokeLog("area ok: " .. tostring(area))

		for _, config in ipairs(GFSmokeLayers) do
			local texture = native.UIWidgetTexture(arg_1_1)

			texture:load(GFSmokeTexture)
			texture:setAnchorPoint(0.5, 0.5)
			texture.alpha = 0
			area:addChild(texture)
			table.insert(arg_1_0.layers, {
				widget = texture,
				config = config
			})
		end

		gfSmokeLog("layers ok: " .. #arg_1_0.layers)

		arg_1_0.area = area
	end)

	if not ok then
		arg_1_0.failed = true

		gfSmokeLog("CTOR FAILED: " .. tostring(err))
	end

	if GFSmokeDebug and GFSmokeDebugStatusSquare then
		local qok, qerr = pcall(function()
			local statusArea = native.UIWidgetArea(arg_1_1)
			local quad = native.UIWidgetQuad(arg_1_1)

			quad.colour = native.SkinColours.FullWhite
			quad.alpha = 1

			quad:setX(0, 20)
			quad:setY(0, 20)
			quad:setWidth(0, 40)
			quad:setHeight(0, 40)
			statusArea:addChild(quad)

			arg_1_0.statusArea = statusArea
			arg_1_0.statusQuad = quad
		end)

		gfSmokeLog("status quad: " .. (qok and "ok" or "FAILED " .. tostring(qerr)))
	end
end)

function GFSmokeHud.registerWithMatchSim(arg_2_0, arg_2_1)
	return
end

function GFSmokeHud.dispose(arg_3_0, arg_3_1)
	if arg_3_0.area then
		arg_3_0.area:dispose()
	end

	if arg_3_0.statusArea then
		arg_3_0.statusArea:dispose()
	end
end

function GFSmokeHud.setStatus(arg_4_0, arg_4_1)
	if arg_4_0.statusQuad and arg_4_0.status ~= arg_4_1 then
		arg_4_0.status = arg_4_1

		pcall(function()
			arg_4_0.statusQuad.colour = native.SkinColours[arg_4_1]
		end)
	end
end

-- The HUD's uiServices is not the services table cutsceneListener is set on
-- (universe.lua sets it on its own services and on the universe), so try the
-- known routes and remember the first that works.
local GFSmokeListenerRoutes = {
	{
		name = "hud.uiServices.cutsceneListener",
		get = function(arg_self)
			return arg_self.hud.uiServices.cutsceneListener
		end
	},
	{
		name = "hud.uiServices.universe.cutsceneListener",
		get = function(arg_self)
			return arg_self.hud.uiServices.universe.cutsceneListener
		end
	},
	{
		name = "engine:getUniverse().cutsceneListener",
		get = function(arg_self)
			return arg_self.engine:getUniverse().cutsceneListener
		end
	}
}

function GFSmokeHud.findCutsceneListener(arg_8_0)
	if arg_8_0.listener then
		return arg_8_0.listener
	end

	for _, route in ipairs(GFSmokeListenerRoutes) do
		local ok, listener = pcall(route.get, arg_8_0)

		if ok and listener then
			arg_8_0.listener = listener

			gfSmokeLog("cutscene listener found via " .. route.name)

			return listener
		end

		if not arg_8_0.loggedRoutes then
			gfSmokeLog("listener route " .. route.name .. ": " .. (ok and "nil" or tostring(listener)))
		end
	end

	arg_8_0.loggedRoutes = true
end

function GFSmokeHud.applyLayers(arg_5_0, arg_5_1)
	for _, layer in ipairs(arg_5_0.layers) do
		local config = layer.config
		local widget = layer.widget
		local size = config.size + config.grow * arg_5_1

		widget:setX(config.x + config.driftX * arg_5_1, 0)
		widget:setY(config.y + config.driftY * arg_5_1, 0)
		widget:setHeight(size, 0)
		widget:setWidth(size / GFSmokeScreenAspect, 0)

		local shotIn = gfSmokeSmoothstep(0, GFSmokeShotFadeIn, arg_5_1)
		local thinned = gfSmokeSmoothstep(config.fadeStart, config.fadeEnd, arg_5_1)

		widget.alpha = config.alpha * shotIn * (1 - (1 - config.sustain) * thinned)
	end
end

function GFSmokeHud.update(arg_6_0, arg_6_1, arg_6_2, arg_6_3, arg_6_4, arg_6_5, arg_6_6, arg_6_7, arg_6_8, arg_6_9, arg_6_10, arg_6_11, arg_6_12)
	arg_6_0.updates = arg_6_0.updates + 1

	local dt = type(arg_6_8) == "number" and arg_6_8 or 0

	arg_6_0.heartbeat = arg_6_0.heartbeat + dt

	if arg_6_0.heartbeat > 10 then
		arg_6_0.heartbeat = 0

		gfSmokeLog(string.format("heartbeat: updates=%d renders=%d enabled=%s failed=%s dt=%s", arg_6_0.updates, arg_6_0.renders, tostring(arg_6_0.enabled), tostring(arg_6_0.failed), tostring(arg_6_8)))
	end

	pcall(function()
		if arg_6_0.statusArea then
			arg_6_0.statusArea:update(arg_6_8)
		end
	end)

	if arg_6_0.failed then
		arg_6_0:setStatus("CommonYellow")

		return
	end

	local ok, err = pcall(function()
		local listener = arg_6_0:findCutsceneListener()
		local cutscene = listener and listener.currentCutscene
		local name = cutscene and tostring(cutscene.name) or nil

		if cutscene ~= arg_6_0.lastSeen then
			arg_6_0.lastSeen = cutscene

			gfSmokeLog(string.format("cutscene now: %s (animset %s) | updates=%d renders=%d", tostring(name), tostring(cutscene and cutscene.animsetName), arg_6_0.updates, arg_6_0.renders))
		end

		local isWide = name ~= nil and name:find(GFSmokeCutscene, 1, true) ~= nil
		local indoor = false

		if isWide then
			arg_6_0.armed = true
		elseif not cutscene then
			arg_6_0.armed = false
		end

		for _, pattern in ipairs(GFSmokeIndoor) do
			if name and name:find(pattern, 1, true) then
				indoor = true
			end
		end

		local show = (arg_6_0.armed and cutscene ~= nil and not indoor) or (GFSmokeDebugAnyCutscene and cutscene ~= nil)

		arg_6_0:setStatus(isWide and "DynastyLightBlue" or "FullWhite")

		if not show then
			arg_6_0.enabled = false
			arg_6_0.cutscene = nil

			return
		end

		if cutscene ~= arg_6_0.cutscene then
			arg_6_0.cutscene = cutscene
			arg_6_0.time = 0
		else
			arg_6_0.time = arg_6_0.time + dt
		end

		arg_6_0:applyLayers(arg_6_0.time)
		arg_6_0.area:update(arg_6_8)

		arg_6_0.enabled = true
	end)

	if not ok then
		arg_6_0.failed = true
		arg_6_0.enabled = false

		gfSmokeLog("UPDATE FAILED: " .. tostring(err))
	end
end

function GFSmokeHud.render(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
	arg_7_0.renders = arg_7_0.renders + 1

	if arg_7_0.enabled and not arg_7_0.failed then
		local ok, err = pcall(function()
			arg_7_0.area:doRender(arg_7_1, arg_7_3)
		end)

		if not ok then
			arg_7_0.failed = true

			gfSmokeLog("RENDER FAILED: " .. tostring(err))
		end
	end

	if arg_7_0.statusArea then
		local sok, serr = pcall(function()
			arg_7_0.statusArea:doRender(arg_7_1, arg_7_3)
		end)

		if not sok and not arg_7_0.loggedStatusError then
			arg_7_0.loggedStatusError = true

			gfSmokeLog("status render error: " .. tostring(serr))
		end
	end
end

-- gf-intro-effects: team walk-out songs for the Grand Final intro.
-- Each song is its own Wwise bank + event "intro_song_<club icon>", added by
-- tools/add_sound_bank.py (PCM, fade-in baked into the Play action). Flow,
-- driven by cutscene names (order verified in-game, see README):
--   rl1_gf_stadium_wide_cam01  -> arm, load both teams' banks, kill the
--                                 stock GF music (sfx_cutscene_music_gf_01)
--   rl1_corridor_<side>        -> fade out whatever plays, start that
--                                 team's song (looped until replaced)
--   second walkout ends        -> fade out before the anthem, unload banks
-- A team without a song gets the stock GF music for its segment instead.

-- Club icons that have an intro_song_<icon> bank installed.
local GFIntroSongs = {
	nrl_broncos = true,
	nrl_roosters = true
}

local GFIntroSongFallbackEvent = "sfx_cutscene_music_gf_01"
local GFIntroSoundObject = "DefaultObject"
local GFIntroStartCutscene = "gf_stadium_wide_cam01"
local GFIntroCrossfadeOut = 2
local GFIntroEndFadeOut = 2.5

-- Fade used when the intro is cut short (the user skips the cutscene).
local GFIntroSkipFadeOut = 1

-- Cutscenes that belong to the GF intro before the anthem. Once armed, any
-- other cutscene - or none at all, which is what a skip leaves - ends the
-- intro effects straight away (music fade, crowd lights + crowd lighting).
local GFIntroPreAnthemCutscenes = {
	"gf_stadium_",
	"intro_lockers",
	"corridor",
	"intro_gf_"
}

local function gfIntroIsPreAnthem(arg_name)
	if not arg_name then
		return false
	end

	for _, pattern in ipairs(GFIntroPreAnthemCutscenes) do
		if arg_name:find(pattern, 1, true) then
			return true
		end
	end

	return false
end

-- Seconds after arming to keep stopping the stock music (its Play is queued
-- on the wide shot's frame 0).
local GFIntroStockMusicStopWindow = 2

-- Seconds after the final fade before the song banks are unloaded.
local GFIntroUnloadDelay = 5

local function gfIntroClubIcon(arg_club)
	local ok, icon = pcall(function()
		local decalIdOrIcon = arg_club.decalIdOrIcon or arg_club.identity.decalIdOrIcon

		return decalIdOrIcon.icon
	end)

	if ok and icon ~= nil and tostring(icon) ~= "" then
		return tostring(icon)
	end
end

Class("GFIntroMusicHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	arg_1_0.hud = arg_1_7
	arg_1_0.engine = arg_1_1
	arg_1_0.failed = false
	arg_1_0.loadedBanks = {}
	arg_1_0.songs = {}

	local ok, err = pcall(function()
		arg_1_0.soundManager = arg_1_1:getSoundManager()

		for _, side in ipairs({
			"home",
			"away"
		}) do
			local icon = gfIntroClubIcon(arg_1_2[side])

			if icon and GFIntroSongs[icon] then
				arg_1_0.songs[side] = "intro_song_" .. icon
			end

			gfSmokeLog("intro music " .. side .. ": icon=" .. tostring(icon) .. " song=" .. tostring(arg_1_0.songs[side]))
		end
	end)

	if not ok then
		arg_1_0.failed = true

		gfSmokeLog("INTRO MUSIC CTOR FAILED: " .. tostring(err))
	end
end)

function GFIntroMusicHud.registerWithMatchSim(arg_2_0, arg_2_1)
	return
end

function GFIntroMusicHud.universe(arg_3_0)
	local ok, universe = pcall(function()
		return arg_3_0.hud.uiServices.universe
	end)

	return ok and universe or nil
end

function GFIntroMusicHud.stopCurrent(arg_4_0, arg_4_1)
	if arg_4_0.playingId then
		local playingId = arg_4_0.playingId

		pcall(function()
			arg_4_0.soundManager:stopEvent(playingId, arg_4_1)
		end)
	end

	arg_4_0.playingId = nil
	arg_4_0.playingEvent = nil
end

function GFIntroMusicHud.play(arg_5_0, arg_5_1)
	local ok, playingId = pcall(function()
		return arg_5_0.soundManager:postEvent(arg_5_1, GFIntroSoundObject)
	end)

	if ok and playingId and playingId ~= 0 then
		arg_5_0.playingId = playingId
		arg_5_0.playingEvent = arg_5_1
	else
		arg_5_0.playingId = nil
		arg_5_0.playingEvent = nil
	end

	gfSmokeLog("intro music play " .. tostring(arg_5_1) .. " -> " .. tostring(ok and playingId or playingId))
end

function GFIntroMusicHud.startSide(arg_6_0, arg_6_1)
	arg_6_0:stopCurrent(GFIntroCrossfadeOut)
	arg_6_0:play(arg_6_0.songs[arg_6_1] or GFIntroSongFallbackEvent)

	arg_6_0.looping = true
end

function GFIntroMusicHud.arm(arg_7_0)
	arg_7_0.armed = true
	arg_7_0.armedTime = 0
	arg_7_0.corridorsSeen = {}
	arg_7_0.finishing = false

	for _, bankName in pairs(arg_7_0.songs) do
		if not arg_7_0.loadedBanks[bankName] then
			local ok, err = pcall(function()
				arg_7_0.soundManager:loadTransitionBank(bankName)
			end)

			arg_7_0.loadedBanks[bankName] = ok

			gfSmokeLog("intro music load " .. bankName .. ": " .. (ok and "ok" or tostring(err)))
		end
	end
end

function GFIntroMusicHud.unloadBanks(arg_8_0)
	for bankName, loaded in pairs(arg_8_0.loadedBanks) do
		if loaded then
			pcall(function()
				arg_8_0.soundManager:unloadBank(bankName)
			end)
		end
	end

	arg_8_0.loadedBanks = {}
end

function GFIntroMusicHud.onCutsceneChanged(arg_9_0, arg_9_1, arg_9_2)
	local name = arg_9_1 or ""
	local previous = arg_9_2 or ""

	if not arg_9_0.armed then
		if name:find(GFIntroStartCutscene, 1, true) then
			arg_9_0:arm()
		end

		return
	end

	if not gfIntroIsPreAnthem(arg_9_1) then
		-- Both teams already out = the normal end (anthem / intro over); otherwise a skip.
		local normalEnd = arg_9_0.corridorsSeen.home and arg_9_0.corridorsSeen.away

		gfSmokeLog("intro music: intro " .. (normalEnd and "ended" or "skipped") .. " (" .. tostring(arg_9_1) .. ")")
		arg_9_0:finish(normalEnd and GFIntroEndFadeOut or GFIntroSkipFadeOut)

		return
	end

	for _, side in ipairs({
		"away",
		"home"
	}) do
		if name:find("rl1_corridor_" .. side, 1, true) and not arg_9_0.corridorsSeen[side] then
			arg_9_0.corridorsSeen[side] = true

			arg_9_0:startSide(side)

			return
		end
	end

	-- The second team's walk-out just ended: clear the music for the anthem.
	local walkoutEnded = previous:find("rl1_intro_gf_home_team", 1, true) or previous:find("rl1_intro_gf_away_team", 1, true)

	if walkoutEnded and arg_9_0.corridorsSeen.home and arg_9_0.corridorsSeen.away and not name:find("rl1_corridor_", 1, true) then
		arg_9_0:finish()
	end
end

function GFIntroMusicHud.finish(arg_10_0, arg_10_1)
	local fade = arg_10_1 or GFIntroEndFadeOut

	arg_10_0.looping = false

	arg_10_0:stopCurrent(fade)

	arg_10_0.armed = false
	arg_10_0.unloadIn = fade + GFIntroUnloadDelay

	gfSmokeLog("intro music finished")
end

function GFIntroMusicHud.update(arg_11_0, arg_11_1, arg_11_2, arg_11_3, arg_11_4, arg_11_5, arg_11_6, arg_11_7, arg_11_8, arg_11_9, arg_11_10, arg_11_11, arg_11_12)
	if arg_11_0.failed then
		return
	end

	local ok, err = pcall(function()
		local dt = type(arg_11_8) == "number" and arg_11_8 or 0
		local universe = arg_11_0:universe()
		local listener = universe and universe.cutsceneListener
		local cutscene = listener and listener.currentCutscene
		local name = cutscene and tostring(cutscene.name) or nil

		if cutscene ~= arg_11_0.lastCutscene then
			local previousName = arg_11_0.lastCutsceneName

			arg_11_0.lastCutscene = cutscene
			arg_11_0.lastCutsceneName = name

			arg_11_0:onCutsceneChanged(name, previousName)
		end

		if arg_11_0.armed then
			arg_11_0.armedTime = arg_11_0.armedTime + dt

			if arg_11_0.armedTime < GFIntroStockMusicStopWindow and universe and universe.soundSystem then
				universe.soundSystem:queueSoundOnlyEvent({
					soundKey = GFIntroSongFallbackEvent,
					fadeTime = 0,
					type = "StopSoundEvent"
				})
			end
		end

		-- Loop: restart the song when it ends while it's still that team's turn.
		if arg_11_0.looping and arg_11_0.playingId and arg_11_0.soundManager:isEventFinished(arg_11_0.playingId) then
			arg_11_0:play(arg_11_0.playingEvent)
		end

		if arg_11_0.unloadIn then
			arg_11_0.unloadIn = arg_11_0.unloadIn - dt

			if arg_11_0.unloadIn <= 0 then
				arg_11_0.unloadIn = nil

				arg_11_0:unloadBanks()
			end
		end
	end)

	if not ok then
		arg_11_0.failed = true

		gfSmokeLog("INTRO MUSIC UPDATE FAILED: " .. tostring(err))

		pcall(function()
			arg_11_0:stopCurrent(1)
		end)
	end
end

function GFIntroMusicHud.render(arg_12_0, arg_12_1, arg_12_2, arg_12_3)
	return
end

function GFIntroMusicHud.dispose(arg_13_0, arg_13_1)
	pcall(function()
		arg_13_0:stopCurrent(0.5)
		arg_13_0:unloadBanks()
	end)
end

-- gf-intro-effects: coloured light blobs scattered across the audience.
-- A rig of soft spotlights hung above the ground (like the stock walk-on spin
-- rig, cinematic_generic_walkon_light_spin_01) each aimed at a random spot in
-- the stands. There is no runtime API to recolour a light, so the rig is its
-- own lighting-scene layer, re-imported GFCrowdUpdateRate times a second with
-- new colours / brightness (the same import/removeLayer calls cutscenes use).
--   wide shot        -> green <-> blue, the blend flowing round the stadium
--   rl1_corridor_<s> -> that team's primary / secondary, alternating
--   always           -> two bright bands chase round the stands, plus random
--                       flicker, so blobs flash on and off
-- The crowd's ambient light is dimmed while the intro runs. Spotlights shine
-- along local +Z (checked against the stock rigs); targetted is never used by
-- shipped lights, so each light's rotation is computed from source -> target.

local GFCrowdLightLayer = "gf_crowd_lights"
local GFCrowdLightCount = 32
local GFCrowdLightSeed = 2026

-- Rig: sources this high, scattered within this fraction of the target ring
-- (near the middle of the ground), aimed at a ring of points in the stands.
-- x runs along the pitch; stadiums are only ever rotated 0 / 180 degrees.
local GFCrowdSourceHeight = 50
local GFCrowdSourceSpread = 0.2
local GFCrowdTargetRadiusX = {
	66,
	88
}
local GFCrowdTargetRadiusZ = {
	44,
	64
}
local GFCrowdTargetHeight = {
	4,
	26
}

-- Blob size (cone angle, degrees) and light settings (from the stock rig).
local GFCrowdSpotAngle = {
	4,
	11
}
local GFCrowdBrightness = 6
local GFCrowdDistance = 200
local GFCrowdSpotSharpness = -1.4
local GFCrowdUseFog = false

-- Re-imports per second (colour / flash resolution).
local GFCrowdUpdateRate = 15

-- Crowd ambient diffuse/specular multiplier while the intro runs (1 = stock).
local GFCrowdDarken = 0.35

local GFCrowdIntroColours = {
	{
		0,
		210,
		80
	},
	{
		0,
		95,
		255
	}
}
local GFCrowdIntroFadePeriod = 4
local GFCrowdTeamSwapPeriod = 1.2

-- Flash: GFCrowdWaveLobes bright bands travel round the stadium at
-- GFCrowdWaveSpeed revolutions per second; a blob is lit while a band covers
-- it (GFCrowdWaveOn = fraction of the wave that is "on"), and each tick a
-- random GFCrowdFlickerChance of blobs dip out for GFCrowdDipDuration.
local GFCrowdWaveLobes = 2
local GFCrowdWaveSpeed = 0.18
local GFCrowdWaveOn = 0.55
local GFCrowdFlickerChance = 0.03

local GFCrowdFadeIn = 1
local GFCrowdFadeOut = 2

-- Per-blob easing so nothing pops: each blob's level eases towards its target
-- (seconds to swing fully on / off), the bands get a wide soft edge, flickers
-- are short eased dips, and brightness follows level ^ GFCrowdBrightnessCurve
-- (HDR exposure makes a linear ramp read as instantly "on"). The whole rig
-- also ramps up over GFCrowdShotFadeIn at the start of each stadium shot.
local GFCrowdBlobFadeIn = 0.6
local GFCrowdBlobFadeOut = 0.9
local GFCrowdWaveSoftness = 0.45
local GFCrowdBrightnessCurve = 2.2
local GFCrowdDipDuration = {
	0.25,
	0.6
}
local GFCrowdShotFadeIn = 0.6

-- Lights only show in these (outdoor) cutscenes; never in lockers/corridors.
local GFCrowdVisibleIn = {
	"gf_stadium_",
	"intro_gf_home_team",
	"intro_gf_away_team"
}

local function gfCrowdLerp(arg_a, arg_b, arg_t)
	return arg_a + (arg_b - arg_a) * arg_t
end

-- Private generator for the rig layout, so the game's global math.random
-- sequence is never reseeded (Park-Miller minimal standard).
local gfCrowdRigSeed = GFCrowdLightSeed

local function gfCrowdRigRandom()
	gfCrowdRigSeed = gfCrowdRigSeed * 16807 % 2147483647

	return gfCrowdRigSeed / 2147483647
end

local function gfCrowdRandomRange(arg_range)
	return gfCrowdLerp(arg_range[1], arg_range[2], gfCrowdRigRandom())
end

-- Rotation taking local +Z (spot direction) onto the unit vector d.
local function gfCrowdAimQuat(arg_dx, arg_dy, arg_dz)
	if arg_dz < -0.9999 then
		return native.quat(0, 1, 0, 0)
	end

	local s = math.sqrt((1 + arg_dz) * 2)

	return native.quat(-arg_dy / s, arg_dx / s, 0, s / 2)
end

local function gfCrowdTeamColour(arg_colour)
	local ok, rgb = pcall(function()
		return {
			arg_colour.r,
			arg_colour.g,
			arg_colour.b
		}
	end)

	if not ok or math.max(rgb[1], rgb[2], rgb[3]) < 40 then
		return {
			255,
			255,
			255
		}
	end

	return rgb
end

Class("GFCrowdLightsHud", function(arg_1_0, arg_1_1, arg_1_2, arg_1_3, arg_1_4, arg_1_5, arg_1_6, arg_1_7)
	arg_1_0.hud = arg_1_7
	arg_1_0.failed = false
	arg_1_0.rig = {}
	arg_1_0.teams = {}

	local ok, err = pcall(function()
		for _, side in ipairs({
			"home",
			"away"
		}) do
			local club = arg_1_2[side]

			arg_1_0.teams[side] = {
				gfCrowdTeamColour(club.primaryColour),
				gfCrowdTeamColour(club.secondaryColour)
			}
		end

		gfCrowdRigSeed = GFCrowdLightSeed

		for i = 1, GFCrowdLightCount do
			-- Even spread round the ring, jittered, so blobs cover every stand.
			local angle = (i - 1 + gfCrowdRigRandom() * 0.8) / GFCrowdLightCount * 2 * math.pi
			local tx = math.cos(angle) * gfCrowdRandomRange(GFCrowdTargetRadiusX)
			local tz = math.sin(angle) * gfCrowdRandomRange(GFCrowdTargetRadiusZ)
			local ty = gfCrowdRandomRange(GFCrowdTargetHeight)
			local sx = (gfCrowdRigRandom() * 2 - 1) * GFCrowdTargetRadiusX[1] * GFCrowdSourceSpread
			local sz = (gfCrowdRigRandom() * 2 - 1) * GFCrowdTargetRadiusZ[1] * GFCrowdSourceSpread
			local dx, dy, dz = tx - sx, ty - GFCrowdSourceHeight, tz - sz
			local len = math.sqrt(dx * dx + dy * dy + dz * dz)

			table.insert(arg_1_0.rig, {
				index = i,
				angle = angle,
				position = {
					sx,
					GFCrowdSourceHeight,
					sz
				},
				aim = {
					dx / len,
					dy / len,
					dz / len
				},
				spotAngle = gfCrowdRandomRange(GFCrowdSpotAngle),
				flicker = false
			})
		end
	end)

	if not ok then
		arg_1_0.failed = true
	end

	gfSmokeLog("crowd lights: " .. (ok and (#arg_1_0.rig .. " rig lights") or ("CTOR FAILED " .. tostring(err))))
end)

function GFCrowdLightsHud.registerWithMatchSim(arg_2_0, arg_2_1)
	return
end

function GFCrowdLightsHud.universe(arg_3_0)
	local ok, universe = pcall(function()
		return arg_3_0.hud.uiServices.universe
	end)

	return ok and universe or nil
end

function GFCrowdLightsHud.setCrowdDarkened(arg_4_0, arg_4_1)
	local universe = arg_4_0:universe()
	local ok, err = pcall(function()
		local env = universe.lightingModule.dynamicEnvironment
		local slices = env.timeFactorCount

		if arg_4_1 then
			if arg_4_0.savedCrowd then
				return
			end

			arg_4_0.savedCrowd = {}

			for slice = 1, slices do
				local diffuse = env:getCrowdAmbientDiffuseIntensityMul(slice)
				local specular = env:getCrowdAmbientSpecularIntensityMul(slice)

				arg_4_0.savedCrowd[slice] = {
					diffuse,
					specular
				}

				env:setCrowdAmbientDiffuseIntensityMul(slice, diffuse * GFCrowdDarken)
				env:setCrowdAmbientSpecularIntensityMul(slice, specular * GFCrowdDarken)
			end

			arg_4_0.crowdEnv = env
		elseif arg_4_0.savedCrowd then
			local saved = arg_4_0.savedCrowd

			arg_4_0.savedCrowd = nil

			for slice, values in pairs(saved) do
				arg_4_0.crowdEnv:setCrowdAmbientDiffuseIntensityMul(slice, values[1])
				arg_4_0.crowdEnv:setCrowdAmbientSpecularIntensityMul(slice, values[2])
			end
		end
	end)

	gfSmokeLog("crowd lights: darken " .. tostring(arg_4_1) .. " -> " .. (ok and "ok" or tostring(err)))
end

function GFCrowdLightsHud.removeLayer(arg_5_0)
	if arg_5_0.layerScene then
		local scene = arg_5_0.layerScene

		arg_5_0.layerScene = nil

		pcall(function()
			scene:removeLayer(GFCrowdLightLayer)
		end)
	end
end

-- Colour of one rig light at time t (seconds since armed).
function GFCrowdLightsHud.lightColour(arg_6_0, arg_6_1, arg_6_2)
	if arg_6_0.side then
		local colours = arg_6_0.teams[arg_6_0.side]
		local swap = math.floor(arg_6_2 / GFCrowdTeamSwapPeriod)

		return colours[(arg_6_1.index + swap) % 2 + 1]
	end

	local a, b = GFCrowdIntroColours[1], GFCrowdIntroColours[2]
	local t = 0.5 + 0.5 * math.sin(2 * math.pi * arg_6_2 / GFCrowdIntroFadePeriod + arg_6_1.angle)

	return {
		gfCrowdLerp(a[1], b[1], t),
		gfCrowdLerp(a[2], b[2], t),
		gfCrowdLerp(a[3], b[3], t)
	}
end

-- 0..1 brightness from the travelling bands.
function GFCrowdLightsHud.lightWave(arg_7_0, arg_7_1, arg_7_2)
	local phase = arg_7_1.angle * GFCrowdWaveLobes - 2 * math.pi * GFCrowdWaveSpeed * GFCrowdWaveLobes * arg_7_2
	local wave = 0.5 + 0.5 * math.cos(phase)
	local edge = 1 - GFCrowdWaveOn

	return gfSmokeSmoothstep(math.max(0, edge - GFCrowdWaveSoftness / 2), math.min(1, edge + GFCrowdWaveSoftness / 2), wave)
end

-- arg_8_1 = seconds since armed, arg_8_2 = master level (0..1), arg_8_3 = seconds since last build.
function GFCrowdLightsHud.buildLayer(arg_8_0, arg_8_1, arg_8_2, arg_8_3)
	local lights = {}

	for _, light in ipairs(arg_8_0.rig) do
		if light.dip then
			light.dip = light.dip - arg_8_3

			if light.dip <= 0 then
				light.dip = nil
			end
		elseif math.random() < GFCrowdFlickerChance then
			light.dip = gfCrowdLerp(GFCrowdDipDuration[1], GFCrowdDipDuration[2], math.random())
		end

		local target = light.dip and 0 or arg_8_0:lightWave(light, arg_8_1)
		local current = light.level or 0
		local rate = target > current and GFCrowdBlobFadeIn or GFCrowdBlobFadeOut
		local step = arg_8_3 / rate

		if math.abs(target - current) <= step then
			current = target
		else
			current = current + (target > current and step or -step)
		end

		light.level = current

		local level = arg_8_2 * current ^ GFCrowdBrightnessCurve

		if level > 0.01 then
			local colour = arg_8_0:lightColour(light, arg_8_1)
			local p, d = light.position, light.aim

			table.insert(lights, {
				class = "CSpotLight",
				data = {
					shadowBlurSigma = 0.0003,
					name = GFCrowdLightLayer .. "_" .. light.index,
					distance = GFCrowdDistance,
					sbrightness = 1,
					cascadeCount = 1,
					drawCascades = false,
					brightness = GFCrowdBrightness * level,
					frontendShadowPlaneOpacity = 1,
					targetted = false,
					shadowCaster = false,
					spotVignette = 1,
					frontendShadowPlaneCascadeDepth = 20,
					attenuationCurve = 2,
					spotAngle = light.spotAngle,
					width = 1,
					thickness = 0,
					height = 2,
					enabled = true,
					fogContributor = GFCrowdUseFog,
					pinToCamera = false,
					visibleInCubeCaptures = false,
					frontendShadowPlaneEnabled = false,
					nightMagic = 0,
					shadowBlurReductionRatio = 0.3,
					spotSharpness = GFCrowdSpotSharpness,
					platform = native.CLightGraphicsSetting[0],
					colour = native.Colour(math.floor(colour[1]), math.floor(colour[2]), math.floor(colour[3])),
					position = native.vec3(p[1], p[2], p[3]),
					rotationQuat = gfCrowdAimQuat(d[1], d[2], d[3]),
					animGroup = native.CLightAnimGroup[0],
					shadowGroup = native.CLightShadowGroup[0],
					shadowMode = native.CLightGraphicsSetting[0],
					target = native.vec3.Zero()
				}
			})
		end
	end

	return lights
end

function GFCrowdLightsHud.onCutsceneChanged(arg_9_0, arg_9_1, arg_9_2)
	local name = arg_9_1 or ""
	local previous = arg_9_2 or ""

	if not arg_9_0.armed then
		if name:find(GFIntroStartCutscene, 1, true) and not arg_9_0.finishedOnce then
			arg_9_0.armed = true
			arg_9_0.time = 0
			arg_9_0.level = 0
			arg_9_0.side = nil
			arg_9_0.corridorsSeen = {}
			arg_9_0.fadingOut = false

			arg_9_0:setCrowdDarkened(true)
			gfSmokeLog("crowd lights: armed")
		end

		return
	end

	if not gfIntroIsPreAnthem(arg_9_1) then
		if not arg_9_0.fadingOut then
			arg_9_0.fadingOut = true

			gfSmokeLog("crowd lights: intro ended early (" .. tostring(arg_9_1) .. ")")
		end

		return
	end

	for _, side in ipairs({
		"away",
		"home"
	}) do
		if name:find("rl1_corridor_" .. side, 1, true) then
			arg_9_0.corridorsSeen[side] = true
			arg_9_0.side = side
		end
	end

	local walkoutEnded = previous:find("rl1_intro_gf_home_team", 1, true) or previous:find("rl1_intro_gf_away_team", 1, true)

	if walkoutEnded and arg_9_0.corridorsSeen.home and arg_9_0.corridorsSeen.away and not name:find("rl1_corridor_", 1, true) then
		arg_9_0.fadingOut = true

		gfSmokeLog("crowd lights: fading out")
	end
end

function GFCrowdLightsHud.update(arg_10_0, arg_10_1, arg_10_2, arg_10_3, arg_10_4, arg_10_5, arg_10_6, arg_10_7, arg_10_8, arg_10_9, arg_10_10, arg_10_11, arg_10_12)
	if arg_10_0.failed then
		return
	end

	local ok, err = pcall(function()
		local dt = type(arg_10_8) == "number" and arg_10_8 or 0
		local universe = arg_10_0:universe()
		local listener = universe and universe.cutsceneListener
		local cutscene = listener and listener.currentCutscene
		local name = cutscene and tostring(cutscene.name) or nil

		if cutscene ~= arg_10_0.lastCutscene then
			local previousName = arg_10_0.lastCutsceneName

			arg_10_0.lastCutscene = cutscene
			arg_10_0.lastCutsceneName = name

			arg_10_0:onCutsceneChanged(name, previousName)
		end

		if not arg_10_0.armed then
			return
		end

		arg_10_0.time = arg_10_0.time + dt

		if arg_10_0.fadingOut then
			arg_10_0.level = math.max(0, arg_10_0.level - dt / GFCrowdFadeOut)
		else
			arg_10_0.level = math.min(1, arg_10_0.level + dt / GFCrowdFadeIn)
		end

		if arg_10_0.fadingOut and arg_10_0.level <= 0 then
			arg_10_0:removeLayer()
			arg_10_0:setCrowdDarkened(false)

			arg_10_0.armed = false
			arg_10_0.finishedOnce = true

			gfSmokeLog("crowd lights: finished")

			return
		end

		local visible = false

		if name then
			for _, pattern in ipairs(GFCrowdVisibleIn) do
				if name:find(pattern, 1, true) then
					visible = true

					break
				end
			end
		end

		if not visible then
			arg_10_0:removeLayer()

			-- Start every blob dark so the next stadium shot fades the rig in.
			arg_10_0.shotLevel = 0
			arg_10_0.tick = nil

			for _, light in ipairs(arg_10_0.rig) do
				light.level = 0
				light.dip = nil
			end

			return
		end

		arg_10_0.shotLevel = math.min(1, (arg_10_0.shotLevel or 0) + dt / GFCrowdShotFadeIn)

		local firstBuild = arg_10_0.tick == nil

		arg_10_0.tick = (arg_10_0.tick or 0) + dt

		if not firstBuild and arg_10_0.tick < 1 / GFCrowdUpdateRate then
			return
		end

		local sinceBuild = arg_10_0.tick

		arg_10_0.tick = 0

		local scene = universe.lightingModule.currentLightingScene

		arg_10_0:removeLayer()

		local lights = arg_10_0:buildLayer(arg_10_0.time, arg_10_0.level * arg_10_0.shotLevel, sinceBuild)

		if #lights > 0 then
			scene:import(lights, GFCrowdLightLayer, GFCrowdLightLayer, native.vec3.Zero(), native.vec3.Zero())

			arg_10_0.layerScene = scene

			if not arg_10_0.loggedFirstImport then
				arg_10_0.loggedFirstImport = true

				gfSmokeLog("crowd lights: first import, " .. #lights .. " lights lit")
			end
		end
	end)

	if not ok then
		arg_10_0.failed = true

		gfSmokeLog("CROWD LIGHTS UPDATE FAILED: " .. tostring(err))

		pcall(function()
			arg_10_0:removeLayer()
			arg_10_0:setCrowdDarkened(false)
		end)
	end
end

function GFCrowdLightsHud.render(arg_11_0, arg_11_1, arg_11_2, arg_11_3)
	return
end

function GFCrowdLightsHud.dispose(arg_12_0, arg_12_1)
	pcall(function()
		arg_12_0:removeLayer()
		arg_12_0:setCrowdDarkened(false)
	end)
end
