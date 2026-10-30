#!/usr/bin/env python3
"""
generate.py - Rebuilds this mod's overrides from the stock sources.

Run from the repo root:  python mods\\loading-screen-secondary-arrows\\generate.py
(build.py skips *.py files, so this script never ends up in a bundle.)

Writes:
  src/script-game/design/loading_setup_helper.lua             team colours sent as an arrow key
  noesis/workspace/views/loadingscreen/loadingscreen_rugby.xaml  every second arrow in the secondary colour

The native loading-screen view model only has HomeTeamColour/AwayTeamColour, so
there is no way to hand it a secondary colour. Instead the Lua sends the primary
with the low 2 bits of each channel replaced by a 6-bit hash of the secondary
(at most 3/255 off, invisible). That colour is unique per (primary, secondary)
pair, and the XAML maps it back to the secondary with one DataTrigger per stock
club. Anything not in the table (custom clubs, online sides) keeps primary-only
arrows.
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(ROOT))

STOCK_LUA = os.path.join(REPO, "decompiled", "src", "script-game", "design", "loading_setup_helper.lua")
STOCK_XAML = os.path.join(REPO, "extracted", "noesis", "workspace", "views", "loadingscreen", "loadingscreen_rugby.xaml")
STOCK_CLUBS = os.path.join(REPO, "decompiled", "defaultdata", "defaultdata_clubs")

OUT_LUA = os.path.join(ROOT, "src", "script-game", "design", "loading_setup_helper.lua")
OUT_XAML = os.path.join(ROOT, "noesis", "workspace", "views", "loadingscreen", "loadingscreen_rugby.xaml")

# Must match ArrowKeyColour in the Lua below.
HASH_MULS = (1, 3, 5)


def secondary_hash(s):
    return (s[0] * HASH_MULS[0] + s[1] * HASH_MULS[1] + s[2] * HASH_MULS[2]) % 64


def arrow_key(p, s):
    h = secondary_hash(s)
    return (p[0] - p[0] % 4 + h % 4, p[1] - p[1] % 4 + (h // 4) % 4, p[2] - p[2] % 4 + h // 16)


def hex_colour(c):
    return "#FF%02X%02X%02X" % tuple(c)


# ---------------------------------------------------------------- club colours

def load_clubs():
    """Stock club records, with any mods/*/defaultdata_clubs overrides merged on top."""
    clubs = {}
    for f in sorted(glob.glob(os.path.join(STOCK_CLUBS, "*.json"))):
        with open(f, encoding="utf-8") as fh:
            clubs[os.path.basename(f)] = json.load(fh)
    for f in sorted(glob.glob(os.path.join(REPO, "mods", "*", "defaultdata", "defaultdata_clubs", "*.json"))):
        name = os.path.basename(f)
        with open(f, encoding="utf-8") as fh:
            clubs.setdefault(name, {}).update(json.load(fh))
    return clubs


def build_table():
    """{key colour: (secondary, [club names])} for every pair with a distinct secondary."""
    table = {}
    for rec in load_clubs().values():
        p = tuple(rec.get("primaryRGBColour") or ())
        s = tuple(rec.get("secondaryRGBColour") or ())
        if len(p) != 3 or len(s) != 3 or p == s:
            continue
        key = arrow_key(p, s)
        if key in table and table[key][0] != s:
            sys.exit("arrow key collision %s: %s vs %s (%s) - change HASH_MULS"
                     % (hex_colour(key), hex_colour(s), hex_colour(table[key][0]), rec["fullName"]))
        table.setdefault(key, (s, []))[1].append(rec["fullName"])
    return table


# ---------------------------------------------------------------- Lua

LUA_HELPER = """\
local function ArrowKeyColour(arg_0_0, arg_0_1)
	local var_0_0 = math.floor(arg_0_0.r)
	local var_0_1 = math.floor(arg_0_0.g)
	local var_0_2 = math.floor(arg_0_0.b)
	local var_0_3 = (math.floor(arg_0_1.r) * %d + math.floor(arg_0_1.g) * %d + math.floor(arg_0_1.b) * %d) %% 64

	return native.NsColor(var_0_0 - var_0_0 %% 4 + var_0_3 %% 4, var_0_1 - var_0_1 %% 4 + math.floor(var_0_3 / 4) %% 4, var_0_2 - var_0_2 %% 4 + math.floor(var_0_3 / 16), 255)
end

""" % HASH_MULS

# Icon clubs load the large_mirrored texture file directly, so the full-size
# HD logo reaches setTeamsLoadingProps (whose 308x312 copy target
# hd-nrl-club-logos' exe patch enlarges); decal (custom) clubs still need
# createTexture.
LUA_LOGO = """\
local function LogoTexture(arg_0_0, arg_0_1, arg_0_2, arg_0_3)
	local var_0_0, var_0_1 = pcall(function()
		return arg_0_0.decalIdOrIcon.icon
	end)

	if var_0_0 and var_0_1 ~= nil and tostring(var_0_1) ~= "" then
		local var_0_2, var_0_3 = pcall(function()
			return arg_0_3:load("ui/club_logos/large_mirrored/" .. tostring(var_0_1) .. ".texture")
		end)

		if var_0_2 and var_0_3 ~= nil then
			return var_0_3
		end
	end

	return arg_0_0.decalIdOrIcon:createTexture(arg_0_1, arg_0_2, arg_0_3, "large_mirrored")
end

"""

# Competition background logo. The loading screen view model's string
# m_loadingText (getLoadingScreen():setLoadingText) is unused by the stock
# rugby XAML, so it carries the competition's CareerCompetitionIdEnum name.
# (CTeamLoadingScreenData.theme is a dead end: Lua can set it, but nothing
# native copies it to the VM's BackgroundLogoTheme.) The competition is only
# known once matchin.finalise has run, which is after SetupLoadingScreen in a
# normal match and before it in a career spectate match, so both ends send it.
STOCK_LOCKDOWN = os.path.join(REPO, "decompiled", "src", "script-game", "app", "match", "matchsetup_lockdown.lua")
OUT_LOCKDOWN = os.path.join(ROOT, "src", "script-game", "app", "match", "matchsetup_lockdown.lua")
STOCK_HIDE_HELPER = os.path.join(REPO, "decompiled", "src", "script-game", "app", "gameplay", "gameplay_loadingscreen_helper.lua")
OUT_HIDE_HELPER = os.path.join(ROOT, "src", "script-game", "app", "gameplay", "gameplay_loadingscreen_helper.lua")

# enum name -> noesis/workspace/images/logos_competition/1080/<file>.png (1080x1080)
COMPETITION_LOGOS = {
    "League_NRL": "nrl",
    "League_NRLW": "nrlw",
    "League_QLDCup": "qld_cup",
    "League_QLDCup2026": "qld_cup",
    "Tournament_StateOfOrigin": "rv_origin",
    "StateOfOrigin": "rv_origin",
    "Tournament_StateOfOriginWomens": "rv_origin_w",
    "Tournament_RLWC2026Men": "rlwc",
    "Tournament_WorldCupMens": "rlwc",
    "WorldCupMens": "rlwc",
    "Tournament_RLWC2026Women": "wrlwc",
    "Tournament_WorldCupWomens": "wrlwc",
    "WorldCupWomens": "wrlwc",
    "League_SuperLeague": "superleague",
    "League_SuperLeague2026": "superleague",
    "SuperLeague": "superleague",
    "League_WSL": "superleague_w",
    "Tournament_ChallengeCup": "challenge_cup",
    "Tournament_ChallengeCup2026": "challenge_cup",
    "Tournament_ChallengeCup2026WithFax": "challenge_cup",
    "Tournament_WomensChallengeCup": "womens_challenge_cup",
    "League_BetfredChampionship": "betfred_championship",
    "League_Championship2026": "betfred_championship",
    "League_Championship2026WithFax": "betfred_championship",
    "KingstoneChampionship": "betfred_championship",
    "League_BetfredLeague1": "betfred_league1",
    "KingstoneLeague1": "betfred_league1",
    "Tournament_EighteenNinteyFiveCup": "1895_cup",
    "Tournament_EighteenNinetyFiveCup2026": "1895_cup",
    "Tournament_EighteenNinetyFiveCup2026WithFax": "1895_cup",
    "Tournament_IndigenousVsMaori": "all_stars",
    "AnzacTest": "rv_pacific",
    "League_NSWCup": "rv_nswcup",
    # Play Now round picker (nrl-field-sponsor-markings round ids, MOD_FIELD_ROUND_ACTIVE)
    "Round_allstars": "all_stars",
    "Round_stateoforigin": "rv_origin",
    "Round_pacific": "rv_pacific",
    "Round_nswcup": "rv_nswcup",
    "Round_qldcup": "qld_cup",
    "Round_country": "rv_country",
    "Round_worldcup": "rlwc",
    "Round_worldcupwomens": "wrlwc",
    # the match's field markings setting (native.MatchSettingsFieldMarkings)
    "Markings_NRL_Rep_AllStarsMatch": "all_stars",
    "Markings_NRL_Rep_StateOfOrigin": "rv_origin",
    "Markings_NRL_Rep_AnzacTest": "rv_pacific",
    "Markings_NRL_Rep_CityVsCountry": "rv_country",
    "Markings_WorldCup": "rlwc",
    "Markings_WorldCupWomens": "wrlwc",
}

# Logos the game doesn't ship, rendered into 1080x1080 textures by install.py
# (premultiplied BGRA, like the stock set) and preloaded with the others. A
# source is a file under the repo, or "stock:<logo>@<top>-<bottom>": rows of a
# stock logos_competition/1080 logo (the Origin shields without the Ampol bar
# above and the "AMPOL STATE OF ORIGIN" text below).
NEW_LOGOS = {
    "rv_pacific": "resources/field-markings/field-centers/pacific-championships-logo.png",
    "rv_nswcup": "resources/nrl-site-logos/nswrl/_competition/badge-light.svg",
    "rv_country": "resources/field-markings/field-centers/footy-country-round.svg",
    "rv_origin": "stock:stateoforigin@120-820",
    "rv_origin_w": "stock:stateoforigin_w@120-820",
}

# Play Now with no competition, round or special markings: club icons pick
# Origin (NSW v QLD) and All Stars (Indigenous v Maori), whose sides only sit in
# the shared "NRL REPRESENTATIVE" league; then (native.AcademyLeagues name, key
# in COMPETITION_LOGOS) - the first league holding both clubs wins.
ORIGIN_ICONS = {"rep_nsw", "rep_qld"}
ALLSTARS_ICONS = {"rep_indigenous", "maori", "rep_allstars"}
CLUB_LEAGUES = [
    ("League_NRL2026", "League_NRL"),
    ("League_NRL", "League_NRL"),
    ("League_NRLW2026", "League_NRLW"),
    ("League_NRLW", "League_NRLW"),
    ("League_NSWCup", "League_NSWCup"),
    ("League_QLDCup2026", "League_QLDCup"),
    ("League_QLDCup", "League_QLDCup"),
    ("League_SuperLeague2026", "League_SuperLeague"),
    ("League_SuperLeague", "League_SuperLeague"),
    ("League_WSL2026", "League_WSL"),
    ("League_WSL", "League_WSL"),
    ("League_Championship2026", "League_BetfredChampionship"),
    ("League_BetfredChampionship", "League_BetfredChampionship"),
    ("League_BetfredLeague1", "League_BetfredLeague1"),
    ("League_WorldCupMen", "Tournament_RLWC2026Men"),
    ("League_WorldCupWomen", "Tournament_RLWC2026Women"),
]

# True: log to loadingscreen_debug.txt (game folder) and show m_loadingText on screen.
DEBUG = False

LUA_COMPETITION = """\
-- Competition background logo: the competition's enum name goes to the
-- loading screen's m_loadingText, which the XAML maps to a logo.
local LOADING_DEBUG = %s

local function LoadingDebugLog(arg_0_0)
	if not LOADING_DEBUG then
		return
	end

	pcall(function()
		local var_0_0 = io.open("loadingscreen_debug.txt", "a")

		if var_0_0 then
			var_0_0:write(os.date("%%H:%%M:%%S ") .. arg_0_0 .. "\\n")
			var_0_0:close()
		end
	end)
end

-- every key the XAML has a logo for; any other value falls through
local LoadingLogoKeys = {
%s}

-- an enum value's name (the enum tables map both ways: name -> id, id -> name)
local function LoadingEnumName(arg_0_0, arg_0_1)
	if arg_0_1 == nil then
		return nil
	end

	if type(arg_0_1) == "string" then
		return arg_0_1
	end

	for iter_0_0, iter_0_1 in pairs(arg_0_0) do
		if type(iter_0_0) == "string" and iter_0_1 == arg_0_1 then
			return iter_0_0
		end
	end

	local var_0_0 = arg_0_0[arg_0_1]

	return type(var_0_0) == "string" and var_0_0 or nil
end

-- Play Now's round pick, then the competition (career, competition mode or a
-- Play Now casualMimicSeason), then the field markings setting.
local function LoadingCompetitionKey(arg_0_0)
	local var_0_0 = {}

	pcall(function()
		local var_0_1 = rawget(_G, "MOD_FIELD_ROUND_ACTIVE")

		if var_0_1 ~= nil then
			table.insert(var_0_0, "Round_" .. tostring(var_0_1))
		end
	end)
	pcall(function()
		local var_0_2 = LoadingEnumName(native.CareerCompetitionIdEnum, arg_0_0.stateOfTheSeason.competitionId)

		if var_0_2 then
			table.insert(var_0_0, var_0_2)
		end
	end)
	pcall(function()
		local var_0_3 = LoadingEnumName(native.MatchSettingsFieldMarkings, arg_0_0.matchType.fieldMarkings)

		if var_0_3 then
			table.insert(var_0_0, "Markings_" .. var_0_3)
		end
	end)

	LoadingDebugLog("candidates: " .. table.concat(var_0_0, ", "))

	for iter_0_0, iter_0_1 in ipairs(var_0_0) do
		if LoadingLogoKeys[iter_0_1] then
			return iter_0_1
		end
	end

	return ""
end

-- Play Now (no competition): NSW v QLD is Origin (women's sides use soow_
-- icons); otherwise the first league, in this order, that holds both clubs
-- picks the logo (as the competition key it would have).
local LoadingOriginIcons = {
%s}

local LoadingAllStarsIcons = {
%s}

local LoadingClubLeagues = {
%s}

local function LoadingClubIcon(arg_0_0)
	local var_0_0, var_0_1 = pcall(function()
		return tostring(arg_0_0.decalIdOrIcon.icon)
	end)

	return var_0_0 and var_0_1 or ""
end

local function LoadingClubLeagueKey(arg_0_0, arg_0_1, arg_0_2)
	local var_0_9 = LoadingClubIcon(arg_0_1)
	local var_0_10 = LoadingClubIcon(arg_0_2)

	if LoadingOriginIcons[var_0_9] and LoadingOriginIcons[var_0_10] then
		return "Tournament_StateOfOrigin"
	end

	if var_0_9:sub(1, 5) == "soow_" and var_0_10:sub(1, 5) == "soow_" then
		return "Tournament_StateOfOriginWomens"
	end

	if LoadingAllStarsIcons[var_0_9] and LoadingAllStarsIcons[var_0_10] then
		return "Tournament_IndigenousVsMaori"
	end

	local var_0_0, var_0_1 = pcall(function()
		local var_0_2 = arg_0_0:getLeagueManager()

		local function var_0_3(arg_1_0)
			local var_1_0 = {}

			for iter_1_0, iter_1_1 in ipairs({
				var_0_2,
				var_0_2.onDisc
			}) do
				pcall(function()
					local var_1_1 = iter_1_1:getLeagueIdsContainingClub(arg_1_0, false)

					for iter_1_2 = 1, #var_1_1 do
						table.insert(var_1_0, var_1_1[iter_1_2])
					end
				end)
			end

			return var_1_0
		end

		local function var_0_4(arg_2_0, arg_2_1)
			for iter_2_0, iter_2_1 in ipairs(arg_2_0) do
				if iter_2_1 == arg_2_1 then
					return true
				end
			end

			return false
		end

		local var_0_5 = var_0_3(arg_0_1)
		local var_0_6 = var_0_3(arg_0_2)

		if LOADING_DEBUG then
			-- every league each club is in: id and name (whatever the league object offers)
			local function var_0_11(arg_3_0)
				local var_3_0 = {}

				for iter_3_0, iter_3_1 in ipairs(arg_3_0) do
					local var_3_1, var_3_2 = pcall(function()
						local var_3_3 = var_0_2:getLeague(iter_3_1)

						return tostring(var_3_3 and (var_3_3.name or var_3_3.fullName or var_3_3.shortName))
					end)

					table.insert(var_3_0, tostring(iter_3_1) .. "=" .. tostring(var_3_2))
				end

				return table.concat(var_3_0, " | ")
			end

			LoadingDebugLog("club icons: " .. LoadingClubIcon(arg_0_1) .. " v " .. LoadingClubIcon(arg_0_2))
			LoadingDebugLog("home leagues: " .. var_0_11(var_0_5))
			LoadingDebugLog("away leagues: " .. var_0_11(var_0_6))
		end

		for iter_0_0, iter_0_1 in ipairs(LoadingClubLeagues) do
			local var_0_7, var_0_8 = pcall(function()
				return var_0_2.onDisc:getLeagueIdBasedOff(native.AcademyLeagues[iter_0_1[1]])
			end)

			LoadingDebugLog("  " .. iter_0_1[1] .. ": ok=" .. tostring(var_0_7) .. " id=" .. tostring(var_0_8) .. " home=" .. tostring(var_0_7 and var_0_4(var_0_5, var_0_8)) .. " away=" .. tostring(var_0_7 and var_0_4(var_0_6, var_0_8)))

			if var_0_7 and var_0_8 ~= nil and var_0_4(var_0_5, var_0_8) and var_0_4(var_0_6, var_0_8) then
				return iter_0_1[2]
			end
		end

		return ""
	end)

	LoadingDebugLog("club guess: ok=" .. tostring(var_0_0) .. " " .. tostring(var_0_1))

	return var_0_0 and var_0_1 or ""
end

-- arg_0_0: true when the screen has just come up after Play - the key is
-- cleared first, so it always changes and the team logos' slide-in (which
-- starts on any competition key) plays every time.
local function SendLoadingCompetition(arg_0_0)
	local var_0_1, var_0_2 = pcall(function()
		local var_0_0 = rawget(_G, "MOD_LOADING_SCREEN")

		if var_0_0 then
			if arg_0_0 then
				var_0_0:setLoadingText("")
			end

			var_0_0:setLoadingText(rawget(_G, "MOD_LOADING_COMPETITION") or "")
		end

		return var_0_0 ~= nil
	end)

	LoadingDebugLog("send: key=" .. tostring(rawget(_G, "MOD_LOADING_COMPETITION")) .. " screen=" .. tostring(var_0_2) .. " ok=" .. tostring(var_0_1))
end

-- Stadium background: "<stadium>_<time of day>" names one of the shipped
-- ui/textures/stadium_images (morning/day/afternoon/dusk/night per ground).
-- arg_0_1: matchin's getTimeOfDayFromHour (matchInData.timeOfDay is the hour)
local function LoadingStadiumKey(arg_0_0, arg_0_1)
	local var_0_0, var_0_1 = pcall(function()
		local var_0_2 = arg_0_0.groundInfo.groundInfo.stadium
		local var_0_3 = LoadingEnumName(native.EStadiums, var_0_2) or tostring(var_0_2)
		local var_0_5 = arg_0_0.timeOfDay

		if type(var_0_5) == "number" and arg_0_1 then
			var_0_5 = arg_0_1(var_0_5)
		end

		local var_0_4 = string.lower(tostring(LoadingEnumName(native.MatchSettingsTimeOfDay, var_0_5) or var_0_5))

		LoadingDebugLog("stadium: " .. tostring(var_0_3) .. " time of day: " .. var_0_4)

		-- the preloaded set is day and night only: dusk kickoffs are under lights
		var_0_4 = (var_0_4 == "dusk" or var_0_4 == "night") and "night" or "day"

		return string.lower(var_0_3) .. "_" .. var_0_4
	end)

	return var_0_0 and var_0_1 or nil
end

-- The stadium background: m_tipsText (getLoadingScreen():setTipsText, unused
-- by this XAML) carries "<stadium>_<day|night>", which the XAML maps to one
-- of the images install.py preloads in the view's texpack.
local function SendLoadingStadium()
	local var_0_0, var_0_1 = pcall(function()
		rawget(_G, "MOD_LOADING_SCREEN"):setTipsText(rawget(_G, "MOD_LOADING_STADIUM") or "")
	end)

	LoadingDebugLog("send stadium: " .. tostring(rawget(_G, "MOD_LOADING_STADIUM")) .. " ok=" .. tostring(var_0_0) .. " " .. tostring(var_0_1))
end

-- called from matchin.finalise (nrl-special-balls' matchin.lua)
rawset(_G, "MOD_LOADING_COMPETITION_HOOK", function(arg_0_0, arg_0_1)
	local var_0_0 = LoadingCompetitionKey(arg_0_0)

	-- no competition (Play Now): keep SetupLoadingScreen's club guess
	if var_0_0 ~= "" or rawget(_G, "MOD_LOADING_COMPETITION") == nil then
		rawset(_G, "MOD_LOADING_COMPETITION", var_0_0)
	end
	LoadingDebugLog("finalise hook: key=" .. tostring(rawget(_G, "MOD_LOADING_COMPETITION")) .. " id=" .. tostring(arg_0_0.stateOfTheSeason and arg_0_0.stateOfTheSeason.competitionId) .. " (" .. type(arg_0_0.stateOfTheSeason and arg_0_0.stateOfTheSeason.competitionId) .. ")")
	SendLoadingCompetition()
	rawset(_G, "MOD_LOADING_STADIUM", LoadingStadiumKey(arg_0_0, arg_0_1))
	SendLoadingStadium()
end)

"""

LUA_COMPETITION_SEND = """\
		LoadingDebugLog("SetupLoadingScreen")
		pcall(function()
			rawset(_G, "MOD_LOADING_SCREEN", arg_1_0:getLoadingScreen())
		end)

		if rawget(_G, "MOD_LOADING_COMPETITION") == nil then
			rawset(_G, "MOD_LOADING_COMPETITION", LoadingClubLeagueKey(arg_1_1, arg_1_2, arg_1_3))
		end
		SendLoadingCompetition(true)
		SendLoadingStadium()

"""

# One Image per logo file with its Source set directly: a relative Source in a
# Style Setter has no base URI to resolve against and never loads.
# The logo shows at full COMPETITION_OPACITY as soon as its key arrives, then
# breathes down to COMPETITION_OPACITY_LOW and back (AutoReverse), forever.
# The pulse starts in each trigger's EnterActions, i.e. when that logo's key
# arrives, so it always begins at the top of the cycle. It animates the Image
# itself (no TargetName: a Style's storyboards can't reach other elements).
COMPETITION_OPACITY = 0.25
COMPETITION_OPACITY_LOW = 0.1
COMPETITION_BREATHE = "00:00:03"  # one way; a full high -> low -> high loop is twice this
COMPETITION_TRIGGER = """\
                                <DataTrigger Binding="{Binding m_loadingText}"
                                             Value="%(key)s">
                                    <Setter Property="Visibility"
                                            Value="Visible" />
                                    <DataTrigger.EnterActions>
                                        <BeginStoryboard x:Name="CompetitionFade_%(key)s">
                                            <Storyboard RepeatBehavior="Forever">
                                                <DoubleAnimation Storyboard.TargetProperty="Opacity"
                                                                 From="%(high)s"
                                                                 To="%(low)s"
                                                                 Duration="%(time)s"
                                                                 AutoReverse="True" />
                                            </Storyboard>
                                        </BeginStoryboard>
                                    </DataTrigger.EnterActions>
                                    <DataTrigger.ExitActions>
                                        <StopStoryboard BeginStoryboardName="CompetitionFade_%(key)s" />
                                    </DataTrigger.ExitActions>
                                </DataTrigger>
"""

COMPETITION_IMAGE = """\
                    <Image Source="../../Images/logos_competition/1080/%s.png"
                           Stretch="Uniform">
                        <Image.Style>
                            <Style TargetType="Image">
                                <Setter Property="Visibility"
                                        Value="Collapsed" />
                                <Setter Property="Opacity"
                                        Value="0" />
                                <Style.Triggers>
%s                                </Style.Triggers>
                            </Style>
                        </Image.Style>
                    </Image>
"""

COMPETITION_DEBUG = """\
                <TextBlock Text="{Binding m_loadingText, FallbackValue='m_loadingText: none'}"
                           Foreground="Yellow"
                           FontSize="18"
                           HorizontalAlignment="Center"
                           VerticalAlignment="Top"
                           Margin="0,200,0,0" />
                <!-- debug A: plain image, no trigger, no animation -->
                <Image Source="../../Images/logos_competition/1080/nrl.png"
                       Width="150"
                       Height="150"
                       HorizontalAlignment="Left"
                       VerticalAlignment="Top"
                       Margin="120,120,0,0" />
                <!-- debug B: DataTrigger on m_loadingText -->
                <TextBlock FontSize="24"
                           HorizontalAlignment="Center"
                           VerticalAlignment="Top"
                           Margin="0,230,0,0">
                    <TextBlock.Style>
                        <Style TargetType="TextBlock">
                            <Setter Property="Text"
                                    Value="no match" />
                            <Setter Property="Foreground"
                                    Value="Yellow" />
                            <Style.Triggers>
                                <DataTrigger Binding="{Binding m_loadingText}"
                                             Value="League_SuperLeague2026">
                                    <Setter Property="Text"
                                            Value="MATCH" />
                                    <Setter Property="Foreground"
                                            Value="Red" />
                                </DataTrigger>
                            </Style.Triggers>
                        </Style>
                    </TextBlock.Style>
                </TextBlock>
                <!-- debug C: triggered image, no animation -->
                <Image Source="../../Images/logos_competition/1080/superleague.png"
                       Width="150"
                       Height="150"
                       HorizontalAlignment="Right"
                       VerticalAlignment="Top"
                       Margin="0,120,120,0">
                    <Image.Style>
                        <Style TargetType="Image">
                            <Setter Property="Visibility"
                                    Value="Collapsed" />
                            <Style.Triggers>
                                <DataTrigger Binding="{Binding m_loadingText}"
                                             Value="League_SuperLeague2026">
                                    <Setter Property="Visibility"
                                            Value="Visible" />
                                </DataTrigger>
                            </Style.Triggers>
                        </Style>
                    </Image.Style>
                </Image>

"""

COMPETITION_LOGO = """\
                <Grid x:Name="CompetitionLogo"
                      Width="560"
                      Height="560"
                      HorizontalAlignment="Center"
                      VerticalAlignment="Center">
%s                </Grid>

"""

# Team logo size in the 1080p layout (stock 542x550, LayoutGrid 1500x550). At
# 4K this is 1360x1376, drawn from hd-nrl-club-logos' 1232x1248 textures.
LOGO_SIZE = (680, 688)
LAYOUT_SIZE = (1700, 700)

# Team logos slide out from the screen centre each time this screen comes up
# after Play. SetupLoadingScreen clears the competition key (m_loadingText) and
# sets it again, so it always changes, and each logo starts its slide when any
# COMPETITION_LOGOS key arrives (the stock IsLoaded and m_showMain signals
# didn't fire at the right time). The slide animates Margin, the property the
# title screen's working animations use: a Margin of (d, 0, -d, 0) shifts the
# logo d to the right. LOGO_SLIDE is the 1080p distance from the centre to
# each logo column's centre.
LOGO_SLIDE = (LAYOUT_SIZE[0] // 2) - (LAYOUT_SIZE[0] // 5)  # 1700-wide grid, columns 2:1:2 -> 510
LOGO_SLIDE_TIME = "00:00:01.4"

TEAM_LOGO_TRIGGER = """\
                                    <DataTrigger Binding="{Binding m_loadingText}"
                                                 Value="%(value)s">
                                        <DataTrigger.EnterActions>
                                            <BeginStoryboard>
                                                <Storyboard>
                                                    <ThicknessAnimation Storyboard.TargetProperty="Margin"
                                                                        From="%(from)d,0,%(to)d,0"
                                                                        To="0,0,0,0"
                                                                        Duration="%(time)s">
                                                        <ThicknessAnimation.EasingFunction>
                                                            <CubicEase EasingMode="EaseOut" />
                                                        </ThicknessAnimation.EasingFunction>
                                                    </ThicknessAnimation>
                                                    <DoubleAnimation Storyboard.TargetProperty="Opacity"
                                                                     From="0"
                                                                     To="1"
                                                                     Duration="00:00:00.8" />
                                                </Storyboard>
                                            </BeginStoryboard>
                                        </DataTrigger.EnterActions>
                                    </DataTrigger>
"""

TEAM_LOGO = """\
                    <Grid Background="{StaticResource %(side)sTeamImage}"
                          VerticalAlignment="Center"
                          Height="%(h)d"
                          Width="%(w)d"%(col)s>
                        <Grid.Style>
                            <Style TargetType="Grid">
                                <Style.Triggers>
%(triggers)s                                </Style.Triggers>
                            </Style>
                        </Grid.Style>
                    </Grid>
"""

# Stadium background: the match's ground at day or night, at STADIUM_OPACITY,
# above the blurred team logos and below the arrows. The Lua sends
# "<stadium>_<day|night>" through m_tipsText; install.py preloads every
# STADIUM_KEYS image (downscaled to STADIUM_SIZE, DXT1, ~135 KB each) in the
# view's texpack under STADIUM_DIR. Only texpack-preloaded textures show in a
# Noesis Image: a texture loaded by Lua's textureManager (bound or static
# path) showed nothing (tested 2026-10-30), and all 458 full-size shipped
# images would be ~1.5 GB.
STADIUM_OPACITY = 0.1
STADIUM_SIZE = (640, 424)  # 1120x740 shipped, DXT1 needs multiples of 4
STADIUM_DIR = "noesis/workspace/images/stadiums"


def stadium_keys():
    """Every "<stadium>_<day|night>" with a shipped ui/textures/stadium_images
    texture in the live game (stadiums from the 1.0.5887 entry list)."""
    sys.path.insert(0, os.path.join(REPO, "tools"))
    import entries
    names = set()
    with open(os.path.join(REPO, "manifests", "entry_index_1.0.5887.csv"), encoding="utf-8") as fh:
        for line in fh:
            m = re.search(r"ui/textures/stadium_images/([a-z0-9_]+_(?:day|night))\.pc\.dds", line)
            if m:
                names.add(m.group(1))
    keys = []
    for key in sorted(names):
        try:
            entries.index_of("ui/textures/stadium_images/%s.texture" % key)
        except Exception:
            continue
        keys.append(key)
    return keys


STADIUM_IMAGE = """\
            <Image Source="../../Images/stadiums/%(key)s.png"
                   Stretch="UniformToFill">
                <Image.Style>
                    <Style TargetType="Image">
                        <Setter Property="Visibility"
                                Value="Collapsed" />
                        <Style.Triggers>
                            <DataTrigger Binding="{Binding m_tipsText}"
                                         Value="%(key)s">
                                <Setter Property="Visibility"
                                        Value="Visible" />
                            </DataTrigger>
                        </Style.Triggers>
                    </Style>
                </Image.Style>
            </Image>
"""

STADIUM_GRID = """\
        <Grid x:Name="StadiumBackground"
              Opacity="%(opacity)s">
%(images)s        </Grid>

"""

STADIUM_DEBUG = """\
        <TextBlock Text="{Binding m_tipsText, FallbackValue='m_tipsText: none'}"
                   Foreground="Yellow"
                   FontSize="18"
                   HorizontalAlignment="Center"
                   VerticalAlignment="Bottom"
                   Margin="0,0,0,60" />

"""

# The stock outline "VS" pair (static, 70px either side of the solid VS)
# becomes a column of outline copies 70px apart that the stock (empty, 4s,
# Forever) vsAnim storyboard scrolls down by VS_STEPS spacings, so the loop is
# seamless. A static opacity mask fades the column in at the top and out at the
# bottom.
VS_SPACING = 70
VS_STEPS = 4  # spacings per 4s vsAnim cycle
VS_RANGE = range(-(VS_STEPS + 7), 7)  # copies at 35 + 70k: covers the 700px column throughout the scroll

VS_OUTLINE = """\
                        <TextBlock Text="VS"
                                   Style="{StaticResource Display_XXL}"
                                   Foreground="Transparent"
                                   noesis:Text.Stroke="White"
                                   noesis:Text.StrokeThickness="2"
                                   FontSize="85"
                                   VerticalAlignment="Center"
                                   HorizontalAlignment="Center">
                            <TextBlock.RenderTransform>
                                <TranslateTransform Y="%d" />
                            </TextBlock.RenderTransform>
                        </TextBlock>
"""

VS_TICKER = """\
                    <Grid Grid.Column="1"
                          ClipToBounds="True"
                          Opacity="0.12">
                        <Grid.OpacityMask>
                            <LinearGradientBrush StartPoint="0.5,0"
                                                 EndPoint="0.5,1">
                                <GradientStop Color="Transparent"
                                              Offset="0" />
                                <GradientStop Color="White"
                                              Offset="0.35" />
                                <GradientStop Color="White"
                                              Offset="0.65" />
                                <GradientStop Color="Transparent"
                                              Offset="1" />
                            </LinearGradientBrush>
                        </Grid.OpacityMask>
                        <Grid x:Name="VsTicker">
                            <Grid.RenderTransform>
                                <TranslateTransform />
                            </Grid.RenderTransform>
%s                        </Grid>
                    </Grid>

"""

VS_ANIM = """\
            <Storyboard x:Key="vsAnim"
                        Duration="00:00:04"
                        RepeatBehavior="Forever">
                <DoubleAnimation Storyboard.TargetName="VsTicker"
                                 Storyboard.TargetProperty="(UIElement.RenderTransform).(TranslateTransform.Y)"
                                 From="0"
                                 To="%d"
                                 Duration="00:00:04" />
            </Storyboard>
"""


def replace_once(text, old, new, what):
    if text.count(old) != 1:
        sys.exit("expected exactly one %s in stock source" % what)
    return text.replace(old, new)


def build_lua():
    with open(STOCK_LUA, encoding="utf-8-sig", newline="") as fh:
        text = fh.read()
    nl = "\r\n" if "\r\n" in text else "\n"
    text = text.replace("\r\n", "\n")

    text = LUA_HELPER + text
    text = replace_once(
        text,
        "\t\tvar_1_5.homeTeamColour = native.NsColor(var_1_6.r, var_1_6.g, var_1_6.b, 255)\n"
        "\t\tvar_1_5.awayTeamColour = native.NsColor(var_1_7.r, var_1_7.g, var_1_7.b, 255)\n",
        "\t\tvar_1_5.homeTeamColour = ArrowKeyColour(var_1_6, arg_1_2.identity.secondaryRGBColour)\n"
        "\t\tvar_1_5.awayTeamColour = ArrowKeyColour(var_1_7, arg_1_3.identity.secondaryRGBColour)\n",
        "SetupLoadingScreen colour block")

    text = replace_once(text, "function SetupLoadingScreen(", LUA_LOGO + "function SetupLoadingScreen(",
                        "SetupLoadingScreen")
    for side, team in (("3", "2"), ("4", "3")):
        text = replace_once(
            text,
            "\t\tlocal var_1_%s = arg_1_%s.decalIdOrIcon:createTexture(var_1_0, var_1_1, var_1_2, \"large_mirrored\")\n"
            % (side, team),
            "\t\tlocal var_1_%s = LogoTexture(arg_1_%s, var_1_0, var_1_1, var_1_2)\n" % (side, team),
            "SetupLoadingScreen createTexture %s" % side)
    text = replace_once(text, "function SetupLoadingScreen(", LUA_COMPETITION % (
                            str(DEBUG).lower(),
                            "".join('\t%s = true,\n' % key for key in sorted(COMPETITION_LOGOS)),
                            "".join('\t%s = true,\n' % icon for icon in sorted(ORIGIN_ICONS)),
                            "".join('\t%s = true,\n' % icon for icon in sorted(ALLSTARS_ICONS)),
                            "".join('\t{\n\t\t"%s",\n\t\t"%s"\n\t},\n' % pair for pair in CLUB_LEAGUES))
                        + "function SetupLoadingScreen(",
                        "SetupLoadingScreen (competition)")
    text = replace_once(text, "\t\tvar_1_5.homeTeamImage = var_1_3\n",
                        LUA_COMPETITION_SEND + "\t\tvar_1_5.homeTeamImage = var_1_3\n", "SetupLoadingScreen homeTeamImage")
    return "﻿" + text.replace("\n", nl)


def build_lockdown():
    """matchsetup_lockdown.lua resetting the competition background logo's key
    at the start of each match."""
    with open(STOCK_LOCKDOWN, encoding="utf-8-sig", newline="") as fh:
        text = fh.read()
    nl = "\r\n" if "\r\n" in text else "\n"
    text = text.replace("\r\n", "\n")
    text = replace_once(text, "\targ_1_0.matchData = arg_1_7\n",
                        "\targ_1_0.matchData = arg_1_7\n\n"
                        "\t-- loading-screen-secondary-arrows: a new match - forget the last competition\n"
                        "\t-- until matchin.finalise reports this one\n"
                        "\trawset(_G, \"MOD_LOADING_COMPETITION\", nil)\n"
                        "\trawset(_G, \"MOD_LOADING_STADIUM\", nil)\n",
                        "MatchSetupLockdown.enter matchData")
    return "﻿" + text.replace("\n", nl)


def build_hide_helper():
    """gameplay_loadingscreen_helper.lua clearing the screen's competition and
    stadium keys when the loading screen hides. SetupLoadingScreen's own
    clear-then-set happens in one go, which the native view model can report
    as no change at all (e.g. NRL after NRL), so the team logos' slide-in
    (an enter trigger on the competition key) never fired."""
    with open(STOCK_HIDE_HELPER, encoding="utf-8-sig", newline="") as fh:
        text = fh.read()
    nl = "\r\n" if "\r\n" in text else "\n"
    text = text.replace("\r\n", "\n")
    text = replace_once(text, "\tvar_1_0:toggleWaitingForPlayersText(false)\n",
                        "\tvar_1_0:toggleWaitingForPlayersText(false)\n\n"
                        "\t-- loading-screen-secondary-arrows: clear the competition and stadium keys once\n"
                        "\t-- the screen is hidden, so the next load's keys are a change (the team logos'\n"
                        "\t-- slide-in starts when a competition key arrives)\n"
                        "\tpcall(function()\n"
                        "\t\tvar_1_0:setLoadingText(\"\")\n"
                        "\t\tvar_1_0:setTipsText(\"\")\n"
                        "\tend)\n",
                        "hideLoadingScreen toggleWaitingForPlayersText")
    return "﻿" + text.replace("\n", nl)


# ---------------------------------------------------------------- XAML

def arrow_style(side, table):
    out = [
        '            <Style x:Key="%sSecondaryArrow"' % side,
        '                   TargetType="Path">',
        '                <Setter Property="Stroke"',
        '                        Value="{StaticResource %sTeamBrush}" />' % side,
        '                <Style.Triggers>',
    ]
    for key in sorted(table):
        sec, names = table[key]
        out += [
            '                    <!--%s-->' % ", ".join(sorted(set(names))).replace("--", "-"),
            '                    <DataTrigger Binding="{Binding %sTeamColour}">' % side,
            '                        <DataTrigger.Value>',
            '                            <Color>%s</Color>' % hex_colour(key),
            '                        </DataTrigger.Value>',
            '                        <Setter Property="Stroke"',
            '                                Value="%s" />' % hex_colour(sec),
            '                    </DataTrigger>',
        ]
    out += [
        '                </Style.Triggers>',
        '            </Style>',
        '',
    ]
    return "\n".join(out) + "\n"


# Every other GlowyLines cycle shows the copy (opposite slot pattern) instead of the stock arrows.
SECONDARY_STORYBOARD = """\
            <Storyboard x:Key="SecondaryArrows"
                        Duration="00:00:02"
                        RepeatBehavior="Forever">
%s            </Storyboard>

"""

SB_TRACK = """\
                <DoubleAnimationUsingKeyFrames Storyboard.TargetName="%s"
                                               Storyboard.TargetProperty="Opacity">
                    <DiscreteDoubleKeyFrame KeyTime="00:00:00"
                                            Value="%d" />
                    <DiscreteDoubleKeyFrame KeyTime="00:00:01"
                                            Value="%d" />
                </DoubleAnimationUsingKeyFrames>
"""


def secondary_style(side):
    return 'Style="{StaticResource %sSecondaryArrow}"' % side


def recolour_even(block, side):
    """Stock StackPanel: paths RL2/RL4/RL6 (LL2/...) get the secondary style."""
    def path(m):
        tag = m.group(0)
        if int(m.group(1)[-1]) % 2:
            return tag
        return tag.replace('Stroke="{StaticResource %sTeamBrush}"' % side, secondary_style(side))

    return re.sub(r'<Path x:Name="(\w+)".*?/>', path, block, flags=re.S)


def secondary_copy(block, sp_name, side):
    """Copy of a lines StackPanel whose paths follow the originals, with the odd paths secondary.

    Each GlowyLines cycle moves every arrow one slot outward and then resets, so the slot
    pattern swaps between the stock panel and this copy every cycle to keep each arrow's colour.
    """
    block = re.sub(r"[ \t]*<!--.*?-->\n", "", block, flags=re.S)
    block = replace_once(block, 'x:Name="%s"' % sp_name, 'x:Name="%sSecondary"' % sp_name, sp_name + " name")
    block = re.sub(r'(<StackPanel[^>]*?)Margin="[^"]*"',
                   r'\1Margin="{Binding ElementName=%s, Path=Margin}"\n                            Opacity="0"' % sp_name,
                   block, count=1, flags=re.S)

    def path(m):
        tag, name = m.group(0), m.group(1)
        tag = re.sub(r'\s*Opacity="[^"]*"', "", tag)
        if int(name[-1]) % 2:
            tag = tag.replace('Stroke="{StaticResource %sTeamBrush}"' % side, secondary_style(side))
        tag = re.sub(r'StrokeThickness="[^"]*"',
                     'StrokeThickness="{Binding ElementName=%s, Path=StrokeThickness}"\n'
                     '                              Opacity="{Binding ElementName=%s, Path=Opacity}"' % (name, name),
                     tag)
        return tag.replace('x:Name="%s"' % name, 'x:Name="%sSecondary"' % name)

    block, n = re.subn(r'<Path x:Name="(\w+)".*?/>', path, block, flags=re.S)
    if n != 6:
        sys.exit("expected 6 arrow paths in %s, found %d" % (sp_name, n))
    return block


def build_xaml(table):
    with open(STOCK_XAML, encoding="utf-8-sig", newline="") as fh:
        text = fh.read()
    nl = "\r\n" if "\r\n" in text else "\n"
    text = text.replace("\r\n", "\n")

    anchor = ('            <SolidColorBrush x:Key="AwayTeamBrush"\n'
              '                             Color="{Binding AwayTeamColour}"\n'
              '                             d:Color="Blue" />\n\n')
    text = replace_once(text, anchor, anchor + arrow_style("Home", table) + arrow_style("Away", table),
                        "AwayTeamBrush resource")

    tracks = "".join(SB_TRACK % (name, a, b) for name, a, b in (
        ("RightLinesSP", 1, 0), ("LeftLinesSP", 1, 0),
        ("RightLinesSPSecondary", 0, 1), ("LeftLinesSPSecondary", 0, 1)))
    anchor = '            <Storyboard x:Key="BGImageAnim"'
    text = replace_once(text, anchor, SECONDARY_STORYBOARD % tracks + anchor,
                        "BGImageAnim storyboard")

    anchor = '            <BeginStoryboard Storyboard="{StaticResource GlowyLines}" />\n'
    text = replace_once(text, anchor,
                        anchor + '            <BeginStoryboard Storyboard="{StaticResource SecondaryArrows}" />\n',
                        "GlowyLines BeginStoryboard")

    for sp_name, side in (("RightLinesSP", "Away"), ("LeftLinesSP", "Home")):
        m = re.search(r'[ \t]*<StackPanel x:Name="%s".*?</StackPanel>\n' % sp_name, text, flags=re.S)
        if not m:
            sys.exit("no %s StackPanel in stock XAML" % sp_name)
        text = (text[:m.start()] + recolour_even(m.group(0), side) + "\n"
                + secondary_copy(m.group(0), sp_name, side) + text[m.end():])

    images = "".join(
        COMPETITION_IMAGE % (logo, "".join(COMPETITION_TRIGGER % {"key": key, "high": COMPETITION_OPACITY, "low": COMPETITION_OPACITY_LOW,
                                                         "time": COMPETITION_BREATHE} for key, f in sorted(COMPETITION_LOGOS.items())
                                           if f == logo))
        for logo in sorted(set(COMPETITION_LOGOS.values())))
    text = replace_once(text, '                <Grid x:Name="LayoutGrid"\n',
                        COMPETITION_LOGO % images + (COMPETITION_DEBUG if DEBUG else "")
                        + '                <Grid x:Name="LayoutGrid"\n',
                        "LayoutGrid (competition logo)")
    text = replace_once(text,
                        '<Grid x:Name="LayoutGrid"\n                      Width="1500"\n                      Height="550"',
                        '<Grid x:Name="LayoutGrid"\n                      Width="%d"\n                      Height="%d"'
                        % LAYOUT_SIZE, "LayoutGrid size")
    for side, col, sign in (("Home", "", 1), ("Away", ' Grid.Column="2"', -1)):
        text = replace_once(text,
                            '                    <Grid Background="{StaticResource %sTeamImage}" VerticalAlignment="Center" '
                            'Height="550" Width="542"%s/>\n' % (side, col),
                            TEAM_LOGO % {"side": side, "col": col, "w": LOGO_SIZE[0], "h": LOGO_SIZE[1],
                                         "triggers": "".join(TEAM_LOGO_TRIGGER % {"value": key, "from": sign * LOGO_SLIDE,
                                                                                  "to": -sign * LOGO_SLIDE,
                                                                                  "time": LOGO_SLIDE_TIME}
                                                             for key in sorted(COMPETITION_LOGOS))},
                            "%s logo" % side)

    # above the blurred team logos (BGImageGrid), below the arrows
    stadiums = "".join(STADIUM_IMAGE % {"key": key} for key in stadium_keys())
    anchor = '        <Controls:baResolutionScaledViewbox HorizontalAlignment="Right">\n'
    text = replace_once(text, anchor, STADIUM_GRID % {"opacity": STADIUM_OPACITY, "images": stadiums} + anchor,
                        "right arrows viewbox (stadium background)")
    if DEBUG:
        anchor = '        <Controls:baScreenControl>\n'
        text = replace_once(text, anchor, STADIUM_DEBUG + anchor, "baScreenControl (stadium debug)")


    m = re.search(r'[ \t]*<TextBlock x:Name="textBlockStroke1".*?</TextBlock>\n\s*'
                  r'<TextBlock x:Name="textBlockStroke2".*?</TextBlock>\n\s*', text, flags=re.S)
    if not m:
        sys.exit("no outline VS pair in stock XAML")
    outlines = "".join(VS_OUTLINE % (VS_SPACING // 2 + VS_SPACING * k) for k in VS_RANGE)
    text = text[:m.start()] + VS_TICKER % outlines + text[m.end():]
    text = replace_once(text,
                        '            <Storyboard x:Key="vsAnim"\n'
                        '                        Duration="00:00:04"\n'
                        '                        RepeatBehavior="Forever">\n'
                        '            </Storyboard>\n',
                        VS_ANIM % (VS_SPACING * VS_STEPS), "empty vsAnim storyboard")

    return "﻿" + text.replace("\n", nl)


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="") as fh:
        fh.write(text)
    print("wrote", os.path.relpath(path, REPO))


def main():
    table = build_table()
    print("%d arrow colour entries" % len(table))
    write(OUT_LUA, build_lua())
    write(OUT_LOCKDOWN, build_lockdown())
    write(OUT_HIDE_HELPER, build_hide_helper())
    write(OUT_XAML, build_xaml(table))


if __name__ == "__main__":
    main()
