items = import("intermediatelua.crowd.crowd_items").items
archetypes = import("intermediatelua.crowd.crowd_archetypes")

-- crowd-team-kits: crowd_rugby.lua dresses fans by the team tag
-- "teamID<academyId>", but crowd_items only has tags for the 2025-era club ids
-- (1-109), so the 2026 clubs (118+) and the internationals fell back to
-- generic clothing. This rebuilds every club's jersey list from its real kits
-- plus the other seasons of the same club, and lends a club's jerseys and merch
-- (polos, caps, beanies, scarves) to its other seasons. Clubs with no merch
-- anywhere keep the native fallback: the homeDefault/awayDefault mask
-- textures, tinted with the club's primary/secondary colours.
--
-- Every texture named here must exist as crowd/characters/textures/<name>:
-- the crowd has its own copies (only the 2025 home/away jerseys), and a
-- missing one aborts the match load. generate.py only emits kits that have one.
--
-- Everything here is local: the native crowd reads this module's globals
-- (items, archetypes). It runs on every match load and gives the same result
-- each time, so the shared crowd_items tables can be patched in place.

-- entries per jersey list, weight copies included. The native cols array holds
-- 16 (rugbyleague1.exe 0xbb0ae9); one more is written through a null pointer.
-- No shipped list is longer than 8; we use the full 16 so older and legacy
-- kits (e.g. rll4-legacy-kits' 2024s) make the cut after home/away.
local COLS_CAPACITY = 16
local MAX_COLS = COLS_CAPACITY
-- copies of the club's own first (home) and second (away) kit; others get 1
local OWN_KIT_WEIGHTS = { 3, 2 }
-- also hand out the colour-tinted default polo to clubs that have their own
-- polo. Untested: the engine may only tint it on the homeDefault fallback
-- path, in which case these fans would wear raw red/yellow mask colours.
local SPRINKLE_TINTED_POLOS = false
local TINTED_POLOS = {
	"crowd_clothes_m_polo_default01_col",
	"crowd_clothes_m_polo_default02_col"
}

-- BEGIN GENERATED (generate.py)
-- club id -> family id (lowest club id sharing the name) and the top
-- textures of its kits that have a crowd copy, in club order
local clubKits = {
	[1] = { family = 1, kits = { "m_top_broncos_nrl_home_25_col", "m_top_broncos_nrl_away_25_col", "m_top_broncos_nrl_alternate_25_col", "m_top_broncos_nrl_indigenous_25_col", "m_top_broncos_nrl_charity_25_col" } }, -- Brisbane Broncos 2025
	[2] = { family = 2, kits = { "m_top_bulldogs_nrl_home_25_col", "m_top_bulldogs_nrl_away_25_col", "m_top_bulldogs_nrl_indigenous_25_col", "m_top_bulldogs_nrl_alternate_25_col", "m_top_bulldogs_nrl_heritage_25_col" } }, -- Canterbury-Bankstown Bulldogs 2025
	[3] = { family = 3, kits = { "m_top_cowboys_nrl_home_25_col", "m_top_cowboys_nrl_away_25_col", "m_top_cowboys_nrl_alternate_25_col", "m_top_cowboys_nrl_indigenous_25_col", "m_top_cowboys_nrl_northernlights_25_col", "m_top_cowboys_nrl_anzac_25_col" } }, -- North Queensland Cowboys 2025
	[4] = { family = 4, kits = { "m_top_dragons_nrl_home_25_col", "m_top_dragons_nrl_away_25_col", "m_top_dragons_nrl_indigenous_25_col", "m_top_dragons_nrl_anzac_25_col" } }, -- St George Illawarra Dragons 2025
	[5] = { family = 5, kits = { "m_top_eels_nrl_home_25_col", "m_top_eels_nrl_away_25_col", "m_top_eels_nrl_indigenous_25_col", "m_top_eels_nrl_heritage_25_col" } }, -- Parramatta Eels 2025
	[6] = { family = 6, kits = { "m_top_knights_nrl_home_25_col", "m_top_knights_nrl_away_25_col", "m_top_knights_nrl_indigenous_25_col", "m_top_knights_nrl_anzac_25_col", "m_top_knights_nrl_mining_25_col" } }, -- Newcastle Knights 2025
	[7] = { family = 7, kits = { "m_top_panthers_nrl_home_25_col", "m_top_panthers_nrl_away_25_col", "m_top_panthers_nrl_alternate_25_col", "m_top_panthers_nrl_indigenous_25_col", "m_top_panthers_nrl_anzac_25_col" } }, -- Penrith Panthers 2025
	[8] = { family = 8, kits = { "m_top_rabbitohs_nrl_home_25_col", "m_top_rabbitohs_nrl_away_25_col", "m_top_rabbitohs_nrl_alternate_25_col", "m_top_rabbitohs_nrl_indigenous_25_col", "m_top_rabbitohs_nrl_anzac_25_col" } }, -- South Sydney Rabbitohs 2025
	[9] = { family = 9, kits = { "m_top_raiders_nrl_home_25_col", "m_top_raiders_nrl_away_25_col", "m_top_raiders_nrl_alternate_25_col", "m_top_raiders_nrl_indigenous_25_col", "m_top_raiders_nrl_anzac_25_col", "m_top_raiders_nrl_home_26_col", "m_top_raiders_nrl_away_26_col" } }, -- Canberra Raiders 2025
	[10] = { family = 10, kits = { "m_top_roosters_nrl_home_25_col", "m_top_roosters_nrl_away_25_col", "m_top_roosters_nrl_indigenous_25_col", "m_top_roosters_nrl_anzac_25_col", "m_top_roosters_nrl_home_26_col", "m_top_roosters_nrl_away_26_col" } }, -- Sydney Roosters 2025
	[11] = { family = 11, kits = { "m_top_seaEagles_nrl_home_25_col", "m_top_seaEagles_nrl_away_25_col", "m_top_seaEagles_nrl_heritage_25_col", "m_top_seaEagles_nrl_indigenous_25_col", "m_top_seaEagles_nrl_anzac_25_col", "m_top_seaEagles_nrl_charity_25_col" } }, -- Manly-Warringah Sea Eagles 2025
	[12] = { family = 12, kits = { "m_top_sharks_nrl_home_25_col", "m_top_sharks_nrl_away_25_col", "m_top_sharks_nrl_indigenous_25_col", "m_top_sharks_nrl_pasifika_25_col", "m_top_sharks_nrl_home_26_col", "m_top_sharks_nrl_away_26_col" } }, -- Cronulla-Sutherland Sharks 2025
	[13] = { family = 13, kits = { "m_top_storm_nrl_home_25_col", "m_top_storm_nrl_away_25_col", "m_top_storm_nrl_indigenous_25_col", "m_top_storm_nrl_alternate_25_col", "m_top_storm_nrl_anzac_25_col", "m_top_storm_nrl_home_26_col", "m_top_storm_nrl_away_26_col" } }, -- Melbourne Storm 2025
	[14] = { family = 14, kits = { "m_top_tigers_nrl_home_25_col", "m_top_tigers_nrl_away_25_col", "m_top_tigers_nrl_indigenous_25_col", "m_top_tigers_nrl_heritage_25_col", "m_top_tigers_nrl_home_26_col", "m_top_tigers_nrl_away_26_col" } }, -- Wests Tigers 2025
	[15] = { family = 15, kits = { "m_top_titans_nrl_home_25_col", "m_top_titans_nrl_away_25_col", "m_top_titans_nrl_indigenous_25_col", "m_top_titans_nrl_anzac_25_col" } }, -- Gold Coast Titans 2025
	[16] = { family = 16, kits = { "m_top_warriors_nrl_home_25_col", "m_top_warriors_nrl_away_25_col", "m_top_warriors_nrl_indigenous_25_col", "m_top_warriors_nrl_anzac_25_col", "m_top_warriors_nrl_pasifika_25_col", "m_top_warriors_nrl_dear_25_col" } }, -- New Zealand Warriors 2025
	[17] = { family = 17, kits = { "m_top_dolphins_nrl_home_25_col", "m_top_dolphins_nrl_away_25_col", "m_top_dolphins_nrl_indigenous_25_col", "m_top_dolphins_nrl_heritage_25_col", "m_top_dolphins_nrl_anzac_25_col", "m_top_dolphins_nrl_home_26_col", "m_top_dolphins_nrl_away_26_col", "m_top_dolphins_nrl_heritage_26_col" } }, -- Dolphins 2025
	[18] = { family = 18, kits = { "m_top_maroons_nrl_home_25_col", "m_top_maroons_nrl_home_26_col", "m_top_qld_rll4_home_2021_col", "m_top_qld_rll4_home_2022_col", "m_top_rep_qld_rll4_2017_col" } }, -- Queensland Maroons
	[19] = { family = 19, kits = { "m_top_blues_nrl_home_25_col", "m_top_blues_nrl_home_26_col", "m_top_nsw_rll4_home_2021_col", "m_top_nsw_rll4_home_2022_col", "m_top_nsw_rll4_home_2023_col", "m_top_nsw_rll4_alternate_2023_col", "m_top_rep_nsw_rll4_2017_col" } }, -- New South Wales Blues
	[20] = { family = 20, kits = { "m_top_tigers_sl_home_25_col", "m_top_tigers_sl_away_25_col", "m_top_tigers_sl_third_25_col" } }, -- Castleford Tigers 2025
	[21] = { family = 21, kits = { "m_top_giants_sl_home_25_col", "m_top_giants_sl_away_25_col", "m_top_giants_sl_third_25_col" } }, -- Huddersfield Giants 2025
	[22] = { family = 22, kits = { "m_top_hullfc_sl_home_25_col", "m_top_hullfc_sl_away_25_col", "m_top_hullfc_sl_third_25_col", "m_top_hullfc_sl_charity_25_col" } }, -- Hull FC 2025
	[23] = { family = 23, kits = { "m_top_rovers_sl_home_25_col", "m_top_rovers_sl_away_25_col", "m_top_rovers_sl_third_25_col" } }, -- Hull KR 2025
	[24] = { family = 24, kits = { "m_top_rhinos_sl_home_25_col", "m_top_rhinos_sl_away_25_col", "m_top_rhinos_sl_away_26_col" } }, -- Leeds Rhinos 2025
	[25] = { family = 25, kits = { "m_top_saints_sl_home_25_col", "m_top_saints_sl_away_25_col", "m_top_saints_sl_third_25_col" } }, -- St. Helens 2025
	[26] = { family = 26, kits = { "m_top_trinity_sl_home_25_col", "m_top_trinity_sl_away_25_col", "m_top_trinity_sl_magic_25_col" } }, -- Wakefield Trinity 2025
	[27] = { family = 27, kits = { "m_top_wolves_sl_home_25_col", "m_top_wolves_sl_away_25_col", "m_top_wolves_sl_alt_25_col", "m_top_wolves_sl_vegas_25_col" } }, -- Warrington Wolves 2025
	[28] = { family = 28, kits = { "m_top_warriors_sl_home_25_col", "m_top_warriors_sl_away_25_col", "m_top_warriors_sl_third_25_col" } }, -- Wigan Warriors 2025
	[29] = { family = 29, kits = { "m_top_leopards_sl_home_25_col", "m_top_leopards_sl_away_25_col", "m_top_leopards_sl_magic_25_col" } }, -- Leigh Leopards 2025
	[30] = { family = 30, kits = { "m_top_dragons_sl_home_25_col", "m_top_dragons_sl_away_25_col", "m_top_dragons_sl_third_25_col" } }, -- Catalans Dragons 2025
	[31] = { family = 31, kits = { "m_top_redDevils_sl_home_25_col", "m_top_redDevils_sl_away_25_col" } }, -- Salford Red Devils 2025
	[32] = { family = 32, kits = {  } }, -- Brisbane Broncos Women
	[33] = { family = 33, kits = {  } }, -- Canberra Raiders Women
	[34] = { family = 34, kits = {  } }, -- Canterbury-Bankstown Bulldogs Women
	[35] = { family = 35, kits = {  } }, -- Cronulla Sharks Women
	[36] = { family = 36, kits = {  } }, -- Gold Coast Titans Women
	[37] = { family = 37, kits = {  } }, -- Newcastle Knights Women
	[38] = { family = 38, kits = {  } }, -- New Zealand Warriors Women
	[39] = { family = 39, kits = {  } }, -- North Queensland Cowboys Women
	[40] = { family = 40, kits = {  } }, -- Parramatta Eels Women
	[41] = { family = 41, kits = {  } }, -- St George Illawarra Dragons Women
	[42] = { family = 42, kits = {  } }, -- Sydney Roosters Women
	[43] = { family = 43, kits = {  } }, -- Wests Tigers Women
	[44] = { family = 44, kits = { "f_top_raiders_wsl_home_25_col", "f_top_raiders_wsl_away_25_col" } }, -- Barrow Raiders Women
	[45] = { family = 45, kits = {  } }, -- Huddersfield Giants Women
	[46] = { family = 46, kits = {  } }, -- Leeds Rhinos Women
	[47] = { family = 47, kits = {  } }, -- Leigh Leopards Women
	[48] = { family = 48, kits = {  } }, -- St. Helens Saints Women
	[49] = { family = 49, kits = {  } }, -- Warrington Wolves Women
	[50] = { family = 50, kits = {  } }, -- Wigan Warriors Women
	[51] = { family = 51, kits = { "f_top_valkyrie_wsl_home_25_col", "f_top_valkyrie_wsl_away_25_col" } }, -- York Valkyrie
	[52] = { family = 52, kits = { "m_top_tigers_qld_home_25_col", "m_top_tigers_qld_away_25_col" } }, -- Brisbane Tigers 2025
	[53] = { family = 53, kits = { "m_top_bears_qld_home_25_col", "m_top_bears_qld_away_25_col" } }, -- Burleigh Bears 2025
	[54] = { family = 54, kits = { "m_top_capras_qld_home_25_col", "m_top_capras_qld_away_25_col" } }, -- Central Queensland Capras 2025
	[55] = { family = 55, kits = { "m_top_jets_qld_home_25_col", "m_top_jets_qld_away_25_col" } }, -- Ipswich Jets 2025
	[56] = { family = 56, kits = { "m_top_cutters_qld_home_25_col", "m_top_cutters_qld_away_25_col" } }, -- Mackay Cutters 2025
	[57] = { family = 57, kits = { "m_top_pride_qld_home_25_col", "m_top_pride_qld_away_25_col" } }, -- Northern Pride 2025
	[58] = { family = 58, kits = { "m_top_devils_qld_home_25_col", "m_top_devils_qld_away_25_col" } }, -- Norths Devils 2025
	[59] = { family = 59, kits = { "m_top_hunters_qld_home_25_col", "m_top_hunters_qld_away_25_col" } }, -- Papua New Guinea Hunters 2025
	[60] = { family = 60, kits = { "m_top_dolphins_qld_home_25_col", "m_top_dolphins_qld_away_25_col" } }, -- Redcliffe Dolphins 2025
	[61] = { family = 61, kits = { "m_top_magpies_qld_home_25_col", "m_top_magpies_qld_away_25_col" } }, -- Souths Logan Magpies 2025
	[62] = { family = 62, kits = { "m_top_falcons_qld_home_25_col", "m_top_falcons_qld_away_25_col" } }, -- Sunshine Coast Falcons 2025
	[63] = { family = 63, kits = { "m_top_blackhawks_qld_home_25_col", "m_top_blackhawks_qld_away_25_col" } }, -- Townsville Blackhawks 2025
	[64] = { family = 64, kits = { "m_top_seagullsTH_qld_home_25_col", "m_top_seagullsTH_qld_away_25_col" } }, -- Tweed Seagulls 2025
	[65] = { family = 65, kits = { "m_top_clydesdales_qld_home_25_col", "m_top_clydesdales_qld_away_25_col" } }, -- Western Clydesdales 2025
	[66] = { family = 66, kits = { "m_top_seagullsWM_qld_home_25_col", "m_top_seagullsWM_qld_away_25_col" } }, -- Wynnum Manly Seagulls 2025
	[67] = { family = 67, kits = { "m_top_nswcup_seaeagles_away_rll4_2017_col", "m_top_nswcup_seaeagles_home_rll4_2017_col" } }, -- Manly-Warringah Sea Eagles NSW Cup
	[68] = { family = 68, kits = {  } }, -- Canberra Raiders NSW Cup
	[69] = { family = 69, kits = { "m_top_nswcup_bulldogs_home_rll4_2017_col" } }, -- Canterbury-Bankstown Bulldogs NSW Cup
	[70] = { family = 70, kits = { "m_top_nswcup_knights_home_rll4_2017_col" } }, -- Newcastle Knights NSW Cup
	[71] = { family = 71, kits = { "m_top_jets_nsw_home_25_col", "m_top_jets_nsw_away_25_col", "m_top_nswcup_jets_away_rll4_2017_col", "m_top_nswcup_jets_home_rll4_2017_col" } }, -- Newtown Jets
	[72] = { family = 72, kits = { "m_top_bears_nsw_home_25_col", "m_top_bears_nsw_away_25_col", "m_top_nswcup_bears_away_rll4_2017_col", "m_top_nswcup_bears_home_rll4_2017_col" } }, -- North Sydney Bears
	[73] = { family = 73, kits = { "m_top_nswcup_panthers_away_rll4_2017_col", "m_top_nswcup_panthers_home_rll4_2017_col" } }, -- Penrith Panthers NSW Cup
	[74] = { family = 74, kits = {  } }, -- Parramatta Eels NSW Cup
	[75] = { family = 75, kits = {  } }, -- South Sydney Rabbitohs NSW Cup
	[76] = { family = 76, kits = {  } }, -- St George Illawarra Dragons NSW Cup
	[77] = { family = 77, kits = {  } }, -- Sydney Roosters NSW Cup
	[78] = { family = 78, kits = { "m_top_nswcup_warriors_away_rll4_2017_col", "m_top_nswcup_warriors_home_rll4_2017_col" } }, -- New Zealand Warriors NSW Cup
	[79] = { family = 79, kits = { "m_top_magpies_nsw_home_25_col", "m_top_magpies_nsw_away_25_col" } }, -- Western Suburbs Magpies
	[80] = { family = 80, kits = { "m_top_panthers_bfc_home_25_col", "m_top_panthers_bfc_away_25_col" } }, -- Halifax Panthers 2025
	[81] = { family = 81, kits = { "m_top_oldham_rfl_home_25_col", "m_top_oldham_rfl_away_25_col" } }, -- Oldham RLFC 2025
	[82] = { family = 82, kits = { "m_top_olympique_bfc_home_25_col", "m_top_olympique_bfc_away_25_col" } }, -- Toulouse Olympique 2025
	[83] = { family = 83, kits = { "m_top_raiders_bfc_home_25_col", "m_top_raiders_bfc_away_25_col" } }, -- Barrow Raiders 2025
	[84] = { family = 84, kits = { "m_top_bulls_bfc_home_25_col", "m_top_bulls_bfc_away_25_col" } }, -- Bradford Bulls 2025
	[85] = { family = 85, kits = { "m_top_vikings_bfc_home_25_col", "m_top_vikings_bfc_away_25_col" } }, -- Widnes Vikings 2025
	[86] = { family = 86, kits = { "m_top_doncaster_rfl_home_25_col", "m_top_doncaster_rfl_away_25_col" } }, -- Doncaster Dons 2025
	[87] = { family = 87, kits = { "m_top_knights_bfc_home_25_col", "m_top_knights_bfc_away_25_col" } }, -- York Knights 2025
	[88] = { family = 88, kits = { "m_top_broncos_bfc_home_25_col", "m_top_broncos_bfc_away_25_col" } }, -- London Broncos 2025
	[89] = { family = 89, kits = { "m_top_bulldogs_bfc_home_25_col", "m_top_bulldogs_bfc_away_25_col" } }, -- Batley Bulldogs 2025
	[90] = { family = 90, kits = { "m_top_eagles_bfc_home_25_col", "m_top_eagles_bfc_away_25_col" } }, -- Sheffield Eagles 2025
	[91] = { family = 91, kits = { "m_top_rovers_bfc_home_25_col", "m_top_rovers_bfc_away_25_col", "m_top_kingstone_rovers_away_rll4_2017_col", "m_top_kingstone_rovers_home_rll4_2017_col" } }, -- Featherstone Rovers 2025
	[92] = { family = 92, kits = { "m_top_hunslet_rfl_home_25_col", "m_top_hunslet_rfl_away_25_col" } }, -- Hunslet RLFC 2025
	[93] = { family = 93, kits = { "m_top_hurricanes_rfl_home_25_col", "m_top_hurricanes_rfl_away_25_col" } }, -- Midlands Hurricanes 2025
	[94] = { family = 94, kits = { "m_top_whitehaven_rfl_home_25_col", "m_top_whitehaven_rfl_away_25_col" } }, -- Whitehaven RLFC 2025
	[95] = { family = 95, kits = { "m_top_crusaders_rfl_home_25_col", "m_top_crusaders_rfl_away_25_col" } }, -- North Wales Crusaders 2025
	[96] = { family = 96, kits = { "m_top_lions_bfc_home_25_col", "m_top_lions_bfc_away_25_col" } }, -- Swinton Lions 2025
	[97] = { family = 97, kits = { "m_top_rams_rfl_home_25_col", "m_top_rams_rfl_away_25_col" } }, -- Dewsbury Rams 2025
	[98] = { family = 98, kits = { "m_top_hornets_rfl_home_25_col", "m_top_hornets_rfl_away_25_col" } }, -- Rochdale Hornets 2025
	[99] = { family = 99, kits = { "m_top_town_rfl_home_25_col", "m_top_town_rfl_away_25_col" } }, -- Workington Town 2025
	[100] = { family = 100, kits = { "m_top_vikings_rfl_home_25_col", "m_top_vikings_rfl_away_25_col" } }, -- Goole Vikings 2025
	[101] = { family = 101, kits = { "m_top_cougars_bfc_home_25_col", "m_top_cougars_bfc_away_25_col" } }, -- Keighley Cougars 2025
	[102] = { family = 102, kits = { "m_top_thunder_bfc_home_25_col", "m_top_thunder_bfc_away_25_col" } }, -- Newcastle Thunder 2025
	[103] = { family = 103, kits = { "m_top_kangaroos_nrl_home_25_col", "m_top_aus_rlwc_home_26_col", "m_top_int_australia_away_rll4_2017_col", "m_top_int_australia_home_rll4_2017_col", "m_top_int_australia_wc_home_rll4_2017_col" } }, -- Australia Kangaroos
	[104] = { family = 104, kits = { "m_top_lions_int_home_25_col", "m_top_eng_rlwc_home_26_col", "m_top_eng_rlwc_home_26_col", "m_top_int_england_home_rll4_2017_col", "m_top_int_england_wc_home_rll4_2017_col" } }, -- England Three Lions
	[105] = { family = 105, kits = { "m_top_indigenous_nrl_home_25_col", "m_top_rep_indallstars_rll4_2017_col" } }, -- Australian Indigenous All Stars
	[106] = { family = 106, kits = { "m_top_maori_nrl_home_25_col" } }, -- New Zealand Maori All Stars
	[107] = { family = 107, kits = { "m_top_halloween_home_25_col", "m_top_halloween_away_25_col", "m_top_halloween_clash_25_col", "m_top_christmas_home_25_col", "m_top_christmas_away_25_col", "m_top_christmas_clash_25_col", "m_top_valentines_home_26_col", "m_top_valentines_away_26_col", "m_top_valentines_clash_26_col", "m_top_bug_qld_26_col", "m_top_bug_nsw_26_col", "m_top_shards_home_26_col", "m_top_decider_home_26_col", "m_top_prideOfNations_home_26_col" } }, -- Pro Team
	[108] = { family = 108, kits = {  } }, -- Queensland Maroons Women
	[109] = { family = 109, kits = {  } }, -- New South Wales Blues Women
	[110] = { family = 1, kits = { "m_top_broncos_nrl_home_25_col", "m_top_broncos_nrl_away_25_col", "m_top_broncos_nrl_alternate_25_col", "m_top_broncos_nrl_indigenous_25_col", "m_top_broncos_nrl_charity_25_col" } }, -- GF Brisbane Broncos
	[111] = { family = 13, kits = { "m_top_storm_nrl_home_25_col", "m_top_storm_nrl_away_25_col", "m_top_storm_nrl_indigenous_25_col", "m_top_storm_nrl_alternate_25_col", "m_top_storm_nrl_anzac_25_col" } }, -- GF Melbourne Storm
	[112] = { family = 32, kits = {  } }, -- GF Brisbane Broncos Women
	[113] = { family = 42, kits = {  } }, -- GF Sydney Roosters Women
	[114] = { family = 18, kits = { "m_top_maroons_nrl_home_25_col" } }, -- Decider Queensland Maroons
	[115] = { family = 19, kits = { "m_top_blues_nrl_home_25_col" } }, -- Decider New South Wales Blues
	[116] = { family = 108, kits = { "f_top_maroons_nrlw_home_25_col" } }, -- Decider Queensland Maroons Women
	[117] = { family = 109, kits = { "f_top_blues_nrlw_home_25_col" } }, -- Decider New South Wales Blues Women
	[118] = { family = 1, kits = { "m_top_broncos_nrl_home_26_col", "m_top_broncos_nrl_away_26_col", "m_top_broncos_nrl_charity_26_col", "m_top_broncos_nrl_heritage_26_col", "m_top_broncos_nrl_home_25_col", "m_top_broncos_nrl_away_25_col", "m_top_broncos_nrl_alternate_25_col", "m_top_broncos_nrl_indigenous_25_col", "m_top_broncos_nrl_charity_25_col", "m_top_broncos_rll4_home_2024_col", "m_top_broncos_rll4_city_2023_col", "m_top_broncos_rll4_indigenous_2022_col", "m_top_broncos_rll4_indigenous_2021_col", "m_top_holden_broncos_away_rll4_2017_col", "m_top_holden_broncos_home_rll4_2017_col", "m_top_nrl_broncos_anzac_rll4_2017_col", "m_top_nrl_broncos_away_rll4_2017_col", "m_top_nrl_broncos_heritage_rll4_2017_col", "m_top_nrl_broncos_home_rll4_2017_col", "m_top_nrl_broncos_indigenous_rll4_2017_col", "m_top_nrl_broncos_nines_rll4_2017_col" } }, -- Brisbane Broncos
	[119] = { family = 2, kits = { "m_top_bulldogs_nrl_home_26_col", "m_top_bulldogs_nrl_away_26_col", "m_top_bulldogs_nrl_home_25_col", "m_top_bulldogs_nrl_away_25_col", "m_top_bulldogs_nrl_indigenous_25_col", "m_top_bulldogs_nrl_alternate_25_col", "m_top_bulldogs_nrl_heritage_25_col", "m_top_bulldogs_rll4_home_2024_col", "m_top_bulldogs_rll4_away_2024_col", "m_top_bulldogs_rll4_anzac_2022_col", "m_top_holden_bulldogs_away_rll4_2017_col", "m_top_holden_bulldogs_home_rll4_2017_col", "m_top_nrl_bulldogs_alternate_rll4_2017_col", "m_top_nrl_bulldogs_anzac_rll4_2017_col", "m_top_nrl_bulldogs_away_rll4_2017_col", "m_top_nrl_bulldogs_heritage_rll4_2017_col", "m_top_nrl_bulldogs_home_rll4_2017_col", "m_top_nrl_bulldogs_indigenous_rll4_2017_col", "m_top_nrl_bulldogs_nines_rll4_2017_col" } }, -- Canterbury-Bankstown Bulldogs
	[120] = { family = 3, kits = { "m_top_cowboys_nrl_home_25_col", "m_top_cowboys_nrl_away_25_col", "m_top_cowboys_nrl_northernlights_25_col", "m_top_cowboys_nrl_alternate_25_col", "m_top_cowboys_nrl_indigenous_25_col", "m_top_cowboys_nrl_northernlights_25_col", "m_top_cowboys_nrl_anzac_25_col", "m_top_cowboys_rll4_home_2024_col", "m_top_cowboys_rll4_away_2024_col", "m_top_cowboys_rll4_anzac_2022_col", "m_top_cowboys_rll4_indigenous_2022_col", "m_top_cowboys_rll4_home_2021_col", "m_top_cowboys_rll4_away_2021_col", "m_top_holden_cowboys_away_rll4_2017_col", "m_top_holden_cowboys_home_rll4_2017_col", "m_top_nrl_cowboys_anzac_rll4_2017_col", "m_top_nrl_cowboys_away_rll4_2017_col", "m_top_nrl_cowboys_home_rll4_2017_col", "m_top_nrl_cowboys_indigenous_rll4_2017_col", "m_top_nrl_cowboys_nines_rll4_2017_col", "m_top_nrl_cowboys_wil_rll4_2017_col" } }, -- North Queensland Cowboys
	[121] = { family = 4, kits = { "m_top_dragons_nrl_home_26_col", "m_top_dragons_nrl_away_26_col", "m_top_dragons_nrl_vegas_26_col", "m_top_dragons_nrl_anzac_26_col", "m_top_dragons_nrl_home_25_col", "m_top_dragons_nrl_away_25_col", "m_top_dragons_nrl_indigenous_25_col", "m_top_dragons_nrl_anzac_25_col", "m_top_dragons_rll4_home_2024_col", "m_top_dragons_rll4_away_2024_col", "m_top_dragons_rll4_anzac_2022_col", "m_top_holden_dragons_away_rll4_2017_col", "m_top_holden_dragons_home_rll4_2017_col", "m_top_nrl_dragons_anzac_rll4_2017_col", "m_top_nrl_dragons_away_rll4_2017_col", "m_top_nrl_dragons_home_rll4_2017_col", "m_top_nrl_dragons_indigenous_rll4_2017_col", "m_top_nrl_dragons_nines_rll4_2017_col" } }, -- St George Illawarra Dragons
	[122] = { family = 5, kits = { "m_top_eels_nrl_home_26_col", "m_top_eels_nrl_away_26_col", "m_top_eels_nrl_indigenous_26_col", "m_top_eels_nrl_alternative_26_col", "m_top_eels_nrl_home_25_col", "m_top_eels_nrl_away_25_col", "m_top_eels_nrl_indigenous_25_col", "m_top_eels_nrl_heritage_25_col", "m_top_eels_rll4_anzac_2022_col", "m_top_eels_rll4_home_2022_col", "m_top_eels_rll4_alternate_2022_col", "m_top_holden_eels_away_rll4_2017_col", "m_top_holden_eels_home_rll4_2017_col", "m_top_nrl_eels_away_rll4_2017_col", "m_top_nrl_eels_heritage_rll4_2017_col", "m_top_nrl_eels_home_rll4_2017_col", "m_top_nrl_eels_indigenous_rll4_2017_col", "m_top_nrl_eels_nines_rll4_2017_col" } }, -- Parramatta Eels
	[123] = { family = 6, kits = { "m_top_knights_nrl_home_26_col", "m_top_knights_nrl_away_26_col", "m_top_knights_nrl_mining_26_col", "m_top_knights_nrl_anzac_26_col", "m_top_knights_nrl_home_25_col", "m_top_knights_nrl_away_25_col", "m_top_knights_nrl_indigenous_25_col", "m_top_knights_nrl_anzac_25_col", "m_top_knights_nrl_mining_25_col", "m_top_knights_rll4_home_2024_col", "m_top_knights_rll4_away_2024_col", "m_top_knights_rll4_anzac_2022_col", "m_top_knights_rll4_anzac_2023_col", "m_top_holden_knights_away_rll4_2017_col", "m_top_holden_knights_home_rll4_2017_col", "m_top_nrl_knights_away_rll4_2017_col", "m_top_nrl_knights_clash_rll4_2017_col", "m_top_nrl_knights_home_rll4_2017_col", "m_top_nrl_knights_indigenous_rll4_2017_col", "m_top_nrl_knights_nines_rll4_2017_col" } }, -- Newcastle Knights
	[124] = { family = 7, kits = { "m_top_panthers_nrl_home_26_col", "m_top_panthers_nrl_away_26_col", "m_top_panthers_nrl_heritage_26_col", "m_top_panthers_nrl_home_25_col", "m_top_panthers_nrl_away_25_col", "m_top_panthers_nrl_alternate_25_col", "m_top_panthers_nrl_indigenous_25_col", "m_top_panthers_nrl_anzac_25_col", "m_top_panthers_rll4_home_2024_col", "m_top_panthers_rll4_away_2024_col", "m_top_panthers_rll4_indigenous_2021_col", "m_top_panthers_rll4_heritage_2022_col", "m_top_holden_panthers_away_rll4_2017_col", "m_top_holden_panthers_home_rll4_2017_col", "m_top_nrl_panthers_away_rll4_2017_col", "m_top_nrl_panthers_clash_rll4_2017_col", "m_top_nrl_panthers_home_rll4_2017_col", "m_top_nrl_panthers_indigenous_rll4_2017_col", "m_top_nrl_panthers_nines_rll4_2017_col" } }, -- Penrith Panthers
	[125] = { family = 8, kits = { "m_top_rabbitohs_nrl_home_26_col", "m_top_rabbitohs_nrl_away_26_col", "m_top_rabbitohs_nrl_home_25_col", "m_top_rabbitohs_nrl_away_25_col", "m_top_rabbitohs_nrl_alternate_25_col", "m_top_rabbitohs_nrl_indigenous_25_col", "m_top_rabbitohs_nrl_anzac_25_col", "m_top_rabbitohs_rll4_home_2024_col", "m_top_rabbitohs_rll4_away_2024_col", "m_top_rabbitohs_rll4_anzac_2022_col", "m_top_rabbitohs_rll4_indigenous_2022_col", "m_top_rabbitohs_rll4_home_2022_col", "m_top_rabbitohs_rll4_away_2022_col", "m_top_holden_rabbitohs_away_rll4_2017_col", "m_top_holden_rabbitohs_home_rll4_2017_col", "m_top_nrl_rabbitohs_anzac_rll4_2017_col", "m_top_nrl_rabbitohs_away_rll4_2017_col", "m_top_nrl_rabbitohs_home_rll4_2017_col", "m_top_nrl_rabbitohs_indigenous_rll4_2017_col", "m_top_nrl_rabbitohs_nines_rll4_2017_col" } }, -- South Sydney Rabbitohs
	[126] = { family = 9, kits = { "m_top_raiders_nrl_home_26_col", "m_top_raiders_nrl_away_26_col", "m_top_raiders_nrl_anzac_26_col", "m_top_raiders_nrl_home_25_col", "m_top_raiders_nrl_away_25_col", "m_top_raiders_nrl_alternate_25_col", "m_top_raiders_nrl_indigenous_25_col", "m_top_raiders_nrl_anzac_25_col", "m_top_raiders_rll4_home_2024_col", "m_top_raiders_rll4_away_2024_col", "m_top_raiders_rll4_alternate_2024_col", "m_top_raiders_rll4_anzac_2024_col", "m_top_holden_raiders_away_rll4_2017_col", "m_top_holden_raiders_home_rll4_2017_col", "m_top_nrl_raiders_away_rll4_2017_col", "m_top_nrl_raiders_clash_rll4_2017_col", "m_top_nrl_raiders_home_rll4_2017_col", "m_top_nrl_raiders_indigenous_rll4_2017_col", "m_top_nrl_raiders_nines_rll4_2017_col" } }, -- Canberra Raiders
	[127] = { family = 10, kits = { "m_top_roosters_nrl_home_26_col", "m_top_roosters_nrl_away_26_col", "m_top_roosters_nrl_anzac_26_col", "m_top_roosters_nrl_home_25_col", "m_top_roosters_nrl_away_25_col", "m_top_roosters_nrl_indigenous_25_col", "m_top_roosters_nrl_anzac_25_col", "m_top_roosters_rll4_home_2024_col", "m_top_roosters_rll4_away_2024_col", "m_top_roosters_rll4_anzac_2022_col", "m_top_roosters_rll4_heritage_2022_col", "m_top_holden_roosters_away_rll4_2017_col", "m_top_holden_roosters_home_rll4_2017_col", "m_top_nrl_roosters_anzac_rll4_2017_col", "m_top_nrl_roosters_away_rll4_2017_col", "m_top_nrl_roosters_home_rll4_2017_col", "m_top_nrl_roosters_indigenous_rll4_2017_col", "m_top_nrl_roosters_nines_away_rll4_2017_col", "m_top_nrl_roosters_nines_rll4_2017_col" } }, -- Sydney Roosters
	[128] = { family = 11, kits = { "m_top_seaEagles_nrl_home_26_col", "m_top_seaEagles_nrl_away_26_col", "m_top_seaEagles_nrl_heritage_26_col", "m_top_seaEagles_nrl_anzac_26_col", "m_top_seaEagles_nrl_home_25_col", "m_top_seaEagles_nrl_away_25_col", "m_top_seaEagles_nrl_heritage_25_col", "m_top_seaEagles_nrl_indigenous_25_col", "m_top_seaEagles_nrl_anzac_25_col", "m_top_seaEagles_nrl_charity_25_col", "m_top_seaeagles_rll4_home_2024_col", "m_top_seaeagles_rll4_away_2024_col", "m_top_seaeagles_rll4_anzac_2024_col", "m_top_seaeagles_rll4_indigenous_2022_col", "m_top_seaeagles_rll4_pride_2022_col", "m_top_seaeagles_rll4_alternate_2022_col", "m_top_seaeagles_rll4_heritage_2022_col", "m_top_seaeagles_rll4_indigenous_2023_col", "m_top_seaeagles_rll4_community_2024_col", "m_top_holden_seaeagles_away_rll4_2017_col", "m_top_holden_seaeagles_home_rll4_2017_col", "m_top_nrl_seaeagles_away_rll4_2017_col", "m_top_nrl_seaeagles_home_rll4_2017_col", "m_top_nrl_seaeagles_indigenous_rll4_2017_col", "m_top_nrl_seaeagles_nines_rll4_2017_col" } }, -- Manly-Warringah Sea Eagles
	[129] = { family = 12, kits = { "m_top_sharks_nrl_home_26_col", "m_top_sharks_nrl_away_26_col", "m_top_sharks_nrl_home_25_col", "m_top_sharks_nrl_away_25_col", "m_top_sharks_nrl_indigenous_25_col", "m_top_sharks_nrl_pasifika_25_col", "m_top_sharks_rll4_home_2024_col", "m_top_sharks_rll4_away_2024_col", "m_top_sharks_rll4_heritage_2022_col", "m_top_sharks_rll4_indigenous_2022_col", "m_top_sharks_rll4_anzac_2022_col", "m_top_holden_sharks_away_rll4_2017_col", "m_top_holden_sharks_home_rll4_2017_col", "m_top_nrl_sharks_away_rll4_2017_col", "m_top_nrl_sharks_heritage_rll4_2017_col", "m_top_nrl_sharks_home_rll4_2017_col", "m_top_nrl_sharks_indigenous_rll4_2017_col", "m_top_nrl_sharks_nines_rll4_2017_col" } }, -- Cronulla-Sutherland Sharks
	[130] = { family = 13, kits = { "m_top_storm_nrl_home_26_col", "m_top_storm_nrl_away_26_col", "m_top_storm_nrl_home_25_col", "m_top_storm_nrl_away_25_col", "m_top_storm_nrl_indigenous_25_col", "m_top_storm_nrl_alternate_25_col", "m_top_storm_nrl_anzac_25_col", "m_top_storm_rll4_indigenous_2022_col", "m_top_holden_storm_away_rll4_2017_col", "m_top_holden_storm_home_rll4_2017_col", "m_top_nrl_storm_away_rll4_2017_col", "m_top_nrl_storm_heritage_rll4_2017_col", "m_top_nrl_storm_home_rll4_2017_col", "m_top_nrl_storm_indigenous_rll4_2017_col", "m_top_nrl_storm_nines_rll4_2017_col", "m_top_nrl_storm_wil_rll4_2017_col" } }, -- Melbourne Storm
	[131] = { family = 14, kits = { "m_top_tigers_nrl_home_26_col", "m_top_tigers_nrl_away_26_col", "m_top_tigers_nrl_home_25_col", "m_top_tigers_nrl_away_25_col", "m_top_tigers_nrl_indigenous_25_col", "m_top_tigers_nrl_heritage_25_col", "m_top_tigers_rll4_home_2024_col", "m_top_tigers_rll4_away_2024_col", "m_top_tigers_rll4_indigenous_2022_col", "m_top_holden_tigers_away_rll4_2017_col", "m_top_holden_tigers_home_rll4_2017_col", "m_top_nrl_tigers_away_rll4_2017_col", "m_top_nrl_tigers_home_rll4_2017_col", "m_top_nrl_tigers_indigenous_rll4_2017_col", "m_top_nrl_tigers_nines_rll4_2017_col" } }, -- Wests Tigers
	[132] = { family = 15, kits = { "m_top_titans_nrl_home_26_col", "m_top_titans_nrl_away_26_col", "m_top_titans_nrl_heritage_26_col", "m_top_titans_nrl_home_25_col", "m_top_titans_nrl_away_25_col", "m_top_titans_nrl_indigenous_25_col", "m_top_titans_nrl_anzac_25_col", "m_top_titans_rll4_home_2024_col", "m_top_titans_rll4_away_2024_col", "m_top_titans_rll4_indigenous_2022_col", "m_top_titans_rll4_home_2022_col", "m_top_titans_rll4_away_2022_col", "m_top_titans_rll4_anzac_2023_col", "m_top_holden_titans_away_rll4_2017_col", "m_top_holden_titans_home_rll4_2017_col", "m_top_nrl_titans_away_rll4_2017_col", "m_top_nrl_titans_clash_rll4_2017_col", "m_top_nrl_titans_heritage_rll4_2017_col", "m_top_nrl_titans_home_rll4_2017_col", "m_top_nrl_titans_indigenous_rll4_2017_col", "m_top_nrl_titans_nines_rll4_2017_col" } }, -- Gold Coast Titans
	[133] = { family = 16, kits = { "m_top_warriors_nrl_home_26_col", "m_top_warriors_nrl_away_26_col", "m_top_warriors_nrl_home_25_col", "m_top_warriors_nrl_away_25_col", "m_top_warriors_nrl_indigenous_25_col", "m_top_warriors_nrl_anzac_25_col", "m_top_warriors_nrl_pasifika_25_col", "m_top_warriors_nrl_dear_25_col", "m_top_warriors_rll4_home_2024_col", "m_top_warriors_rll4_away_2024_col", "m_top_warriors_rll4_heritage_2022_col", "m_top_warriors_rll4_heritage_2023_col", "m_top_holden_warriors_away_rll4_2017_col", "m_top_holden_warriors_home_rll4_2017_col", "m_top_nrl_warriors_away_rll4_2017_col", "m_top_nrl_warriors_heritage_rll4_2017_col", "m_top_nrl_warriors_home_rll4_2017_col", "m_top_nrl_warriors_nines_rll4_2017_col", "m_top_nrl_warriors_wil_rll4_2017_col" } }, -- New Zealand Warriors
	[134] = { family = 17, kits = { "m_top_dolphins_nrl_home_26_col", "m_top_dolphins_nrl_away_26_col", "m_top_dolphins_nrl_heritage_26_col", "m_top_dolphins_nrl_home_25_col", "m_top_dolphins_nrl_away_25_col", "m_top_dolphins_nrl_indigenous_25_col", "m_top_dolphins_nrl_heritage_25_col", "m_top_dolphins_nrl_anzac_25_col", "m_top_dolphins_rll4_home_2024_col", "m_top_dolphins_rll4_away_2024_col", "m_top_dolphins_rll4_alternate_2024_col", "m_top_dolphins_rll4_anzac_2024_col", "m_top_dolphins_rll4_anzac_2023_col" } }, -- Dolphins
	[135] = { family = 20, kits = { "m_top_tigers_sl_home_26_col", "m_top_tigers_sl_away_26_col", "m_top_tigers_sl_home_25_col", "m_top_tigers_sl_away_25_col", "m_top_tigers_sl_third_25_col", "m_top_sl_tigers_away_rll4_2017_col", "m_top_sl_tigers_home_rll4_2017_col" } }, -- Castleford Tigers
	[136] = { family = 21, kits = { "m_top_giants_sl_home_26_col", "m_top_giants_sl_away_26_col", "m_top_giants_sl_home_25_col", "m_top_giants_sl_away_25_col", "m_top_giants_sl_third_25_col", "m_top_sl_giants_away_rll4_2017_col", "m_top_sl_giants_home_rll4_2017_col" } }, -- Huddersfield Giants
	[137] = { family = 22, kits = { "m_top_hullfc_sl_home_25_col", "m_top_hullfc_sl_away_25_col", "m_top_hullfc_sl_third_25_col", "m_top_hullfc_sl_charity_25_col", "m_top_sl_hullfc_away_rll4_2017_col", "m_top_sl_hullfc_home_rll4_2017_col" } }, -- Hull FC
	[138] = { family = 23, kits = { "m_top_rovers_sl_home_26_col", "m_top_rovers_sl_away_26_col", "m_top_rovers_sl_vegas_26_col", "m_top_rovers_sl_home_25_col", "m_top_rovers_sl_away_25_col", "m_top_rovers_sl_third_25_col", "m_top_kingstone_hull_away_rll4_2017_col", "m_top_kingstone_hull_home_rll4_2017_col" } }, -- Hull KR
	[139] = { family = 24, kits = { "m_top_rhinos_sl_home_26_col", "m_top_rhinos_sl_away_26_col", "m_top_rhinos_sl_vegas_26_col", "m_top_rhinos_sl_home_25_col", "m_top_rhinos_sl_away_25_col", "m_top_rhinos_sl_away_26_col", "m_top_sl_rhinos_away_rll4_2017_col", "m_top_sl_rhinos_home_rll4_2017_col" } }, -- Leeds Rhinos
	[140] = { family = 25, kits = { "m_top_saints_sl_home_26_col", "m_top_saints_sl_away_26_col", "m_top_saints_sl_home_25_col", "m_top_saints_sl_away_25_col", "m_top_saints_sl_third_25_col", "m_top_sl_sthelens_away_rll4_2017_col", "m_top_sl_sthelens_home_rll4_2017_col" } }, -- St. Helens
	[141] = { family = 26, kits = { "m_top_trinity_sl_home_26_col", "m_top_trinity_sl_away_26_col", "m_top_trinity_sl_home_25_col", "m_top_trinity_sl_away_25_col", "m_top_trinity_sl_magic_25_col", "m_top_sl_wildcats_away_rll4_2017_col", "m_top_sl_wildcats_home_rll4_2017_col" } }, -- Wakefield Trinity
	[142] = { family = 27, kits = { "m_top_wolves_sl_home_26_col", "m_top_wolves_sl_away_26_col", "m_top_wolves_sl_home_25_col", "m_top_wolves_sl_away_25_col", "m_top_wolves_sl_alt_25_col", "m_top_wolves_sl_vegas_25_col", "m_top_sl_wolves_away_rll4_2017_col", "m_top_sl_wolves_home_rll4_2017_col" } }, -- Warrington Wolves
	[143] = { family = 28, kits = { "m_top_warriors_sl_home_26_col", "m_top_warriors_sl_away_26_col", "m_top_warriors_sl_home_25_col", "m_top_warriors_sl_away_25_col", "m_top_warriors_sl_third_25_col", "m_top_sl_warriors_away_rll4_2017_col", "m_top_sl_warriors_home_rll4_2017_col" } }, -- Wigan Warriors
	[144] = { family = 29, kits = { "m_top_leopards_sl_home_25_col", "m_top_leopards_sl_away_25_col", "m_top_leopards_sl_magic_25_col", "m_top_sl_centurions_away_rll4_2017_col", "m_top_sl_centurions_home_rll4_2017_col" } }, -- Leigh Leopards
	[145] = { family = 30, kits = { "m_top_dragons_sl_home_26_col", "m_top_dragons_sl_away_26_col", "m_top_dragons_sl_home_25_col", "m_top_dragons_sl_away_25_col", "m_top_dragons_sl_third_25_col", "m_top_sl_dragons_away_rll4_2017_col", "m_top_sl_dragons_home_rll4_2017_col" } }, -- Catalans Dragons
	[146] = { family = 84, kits = { "m_top_bulls_bfc_home_26_col", "m_top_bulls_bfc_away_26_col", "m_top_bulls_bfc_home_25_col", "m_top_bulls_bfc_away_25_col", "m_top_kingstone_bulls_away_rll4_2017_col", "m_top_kingstone_bulls_home_rll4_2017_col" } }, -- Bradford Bulls
	[147] = { family = 82, kits = { "m_top_olympique_bfc_home_26_col", "m_top_olympique_bfc_away_26_col", "m_top_olympique_bfc_home_25_col", "m_top_olympique_bfc_away_25_col", "m_top_kingstone_olympique_away_rll4_2017_col", "m_top_kingstone_olympique_home_rll4_2017_col" } }, -- Toulouse Olympique
	[148] = { family = 87, kits = { "m_top_knights_bfc_home_26_col", "m_top_knights_bfc_away_26_col", "m_top_knights_bfc_home_25_col", "m_top_knights_bfc_away_25_col", "m_top_kingstone_1_knights_away_rll4_2017_col", "m_top_kingstone_1_knights_home_rll4_2017_col" } }, -- York Knights
	[149] = { family = 52, kits = { "m_top_tigers_qld_home_25_col", "m_top_tigers_qld_away_25_col", "m_top_qldcup_tigers_away_rll4_2017_col", "m_top_qldcup_tigers_home_rll4_2017_col" } }, -- Brisbane Tigers
	[150] = { family = 53, kits = { "m_top_bears_qld_home_25_col", "m_top_bears_qld_away_25_col", "m_top_qldcup_bears_away_rll4_2017_col", "m_top_qldcup_bears_home_rll4_2017_col" } }, -- Burleigh Bears
	[151] = { family = 54, kits = { "m_top_capras_qld_home_25_col", "m_top_capras_qld_away_25_col", "m_top_qldcup_capras_away_rll4_2017_col", "m_top_qldcup_capras_home_rll4_2017_col" } }, -- Central Queensland Capras
	[152] = { family = 55, kits = { "m_top_jets_qld_home_25_col", "m_top_jets_qld_away_25_col", "m_top_qldcup_jets_away_rll4_2017_col", "m_top_qldcup_jets_home_rll4_2017_col" } }, -- Ipswich Jets
	[153] = { family = 56, kits = { "m_top_cutters_qld_home_25_col", "m_top_cutters_qld_away_25_col", "m_top_qldcup_cutters_away_rll4_2017_col", "m_top_qldcup_cutters_home_rll4_2017_col" } }, -- Mackay Cutters
	[154] = { family = 57, kits = { "m_top_pride_qld_home_25_col", "m_top_pride_qld_away_25_col", "m_top_qldcup_pride_away_rll4_2017_col", "m_top_qldcup_pride_home_rll4_2017_col" } }, -- Northern Pride
	[155] = { family = 58, kits = { "m_top_devils_qld_home_25_col", "m_top_devils_qld_away_25_col", "m_top_qldcup_devils_away_rll4_2017_col", "m_top_qldcup_devils_home_rll4_2017_col" } }, -- Norths Devils
	[156] = { family = 59, kits = { "m_top_hunters_qld_home_25_col", "m_top_hunters_qld_away_25_col", "m_top_qldcup_hunters_away_rll4_2017_col", "m_top_qldcup_hunters_home_rll4_2017_col" } }, -- Papua New Guinea Hunters
	[157] = { family = 60, kits = { "m_top_dolphins_qld_home_25_col", "m_top_dolphins_qld_away_25_col", "m_top_qldcup_dolphins_away_rll4_2017_col", "m_top_qldcup_dolphins_home_rll4_2017_col" } }, -- Redcliffe Dolphins
	[158] = { family = 61, kits = { "m_top_magpies_qld_home_25_col", "m_top_magpies_qld_away_25_col", "m_top_qldcup_magpies_away_rll4_2017_col", "m_top_qldcup_magpies_home_rll4_2017_col" } }, -- Souths Logan Magpies
	[159] = { family = 62, kits = { "m_top_falcons_qld_home_25_col", "m_top_falcons_qld_away_25_col", "m_top_qldcup_falcons_away_rll4_2017_col", "m_top_qldcup_falcons_home_rll4_2017_col" } }, -- Sunshine Coast Falcons
	[160] = { family = 63, kits = { "m_top_blackhawks_qld_home_25_col", "m_top_blackhawks_qld_away_25_col", "m_top_qldcup_blackhawks_away_rll4_2017_col", "m_top_qldcup_blackhawks_home_rll4_2017_col" } }, -- Townsville Blackhawks
	[161] = { family = 64, kits = { "m_top_seagullsTH_qld_home_25_col", "m_top_seagullsTH_qld_away_25_col", "m_top_qldcup_seagulls_away_rll4_2017_col", "m_top_qldcup_seagulls_home_rll4_2017_col" } }, -- Tweed Seagulls
	[162] = { family = 65, kits = { "m_top_clydesdales_qld_home_25_col", "m_top_clydesdales_qld_away_25_col" } }, -- Western Clydesdales
	[163] = { family = 66, kits = { "m_top_seagullsWM_qld_home_25_col", "m_top_seagullsWM_qld_away_25_col", "m_top_qldcup_manlyseagulls_away_rll4_2017_col", "m_top_qldcup_manlyseagulls_home_rll4_2017_col" } }, -- Wynnum Manly Seagulls
	[164] = { family = 31, kits = { "m_top_redDevils_sl_home_26_col", "m_top_redDevils_sl_away_26_col", "m_top_redDevils_sl_home_25_col", "m_top_redDevils_sl_away_25_col", "m_top_sl_devils_away_rll4_2017_col", "m_top_sl_devils_home_rll4_2017_col" } }, -- Salford RLFC
	[165] = { family = 80, kits = { "m_top_panthers_bfc_home_26_col", "m_top_panthers_bfc_away_26_col", "m_top_panthers_bfc_home_25_col", "m_top_panthers_bfc_away_25_col", "m_top_kingstone_halifax_away_rll4_2017_col", "m_top_kingstone_halifax_home_rll4_2017_col" } }, -- Halifax Panthers
	[166] = { family = 81, kits = { "m_top_oldham_rfl_home_26_col", "m_top_oldham_rfl_away_26_col", "m_top_oldham_rfl_home_25_col", "m_top_oldham_rfl_away_25_col", "m_top_kingstone_oldham_away_rll4_2017_col", "m_top_kingstone_oldham_home_rll4_2017_col" } }, -- Oldham RLFC
	[167] = { family = 83, kits = { "m_top_raiders_bfc_home_26_col", "m_top_raiders_bfc_away_26_col", "m_top_raiders_bfc_home_25_col", "m_top_raiders_bfc_away_25_col", "m_top_kingstone_1_raiders_away_rll4_2017_col", "m_top_kingstone_1_raiders_home_rll4_2017_col" } }, -- Barrow Raiders
	[168] = { family = 85, kits = { "m_top_vikings_bfc_home_26_col", "m_top_vikings_bfc_away_26_col", "m_top_vikings_bfc_home_25_col", "m_top_vikings_bfc_away_25_col", "m_top_sl_vikings_away_rll4_2017_col", "m_top_sl_vikings_home_rll4_2017_col" } }, -- Widnes Vikings
	[169] = { family = 86, kits = { "m_top_doncaster_rfl_home_26_col", "m_top_doncaster_rfl_away_26_col", "m_top_doncaster_rfl_home_25_col", "m_top_doncaster_rfl_away_25_col", "m_top_kingstone_1_doncaster_away_rll4_2017_col", "m_top_kingstone_1_doncaster_home_rll4_2017_col" } }, -- Doncaster Dons
	[170] = { family = 88, kits = { "m_top_broncos_bfc_home_26_col", "m_top_broncos_bfc_away_26_col", "m_top_broncos_bfc_home_25_col", "m_top_broncos_bfc_away_25_col", "m_top_kingstone_broncos_away_rll4_2017_col", "m_top_kingstone_broncos_home_rll4_2017_col" } }, -- London Broncos
	[171] = { family = 89, kits = { "m_top_bulldogs_bfc_home_26_col", "m_top_bulldogs_bfc_away_26_col", "m_top_bulldogs_bfc_home_25_col", "m_top_bulldogs_bfc_away_25_col", "m_top_kingstone_bulldogs_away_rll4_2017_col", "m_top_kingstone_bulldogs_home_rll4_2017_col" } }, -- Batley Bulldogs
	[172] = { family = 90, kits = { "m_top_eagles_bfc_home_26_col", "m_top_eagles_bfc_away_26_col", "m_top_eagles_bfc_home_25_col", "m_top_eagles_bfc_away_25_col", "m_top_kingstone_eagles_away_rll4_2017_col", "m_top_kingstone_eagles_home_rll4_2017_col" } }, -- Sheffield Eagles
	[173] = { family = 92, kits = { "m_top_hunslet_rfl_home_26_col", "m_top_hunslet_rfl_away_26_col", "m_top_hunslet_rfl_home_25_col", "m_top_hunslet_rfl_away_25_col", "m_top_kingstone_1_hawks_away_rll4_2017_col", "m_top_kingstone_1_hawks_home_rll4_2017_col" } }, -- Hunslet RLFC
	[174] = { family = 93, kits = { "m_top_hurricanes_rfl_home_26_col", "m_top_hurricanes_rfl_away_26_col", "m_top_hurricanes_rfl_home_25_col", "m_top_hurricanes_rfl_away_25_col" } }, -- Midlands Hurricanes
	[175] = { family = 94, kits = { "m_top_whitehaven_rfl_home_26_col", "m_top_whitehaven_rfl_away_26_col", "m_top_whitehaven_rfl_home_25_col", "m_top_whitehaven_rfl_away_25_col", "m_top_kingstone_1_whitehaven_away_rll4_2017_col", "m_top_kingstone_1_whitehaven_home_rll4_2017_col" } }, -- Whitehaven RLFC
	[176] = { family = 95, kits = { "m_top_crusaders_rfl_home_26_col", "m_top_crusaders_rfl_away_26_col", "m_top_crusaders_rfl_home_25_col", "m_top_crusaders_rfl_away_25_col", "m_top_kingstone_1_crusaders_away_rll4_2017_col", "m_top_kingstone_1_crusaders_home_rll4_2017_col" } }, -- North Wales Crusaders
	[177] = { family = 96, kits = { "m_top_lions_bfc_home_26_col", "m_top_lions_bfc_away_26_col", "m_top_lions_bfc_home_25_col", "m_top_lions_bfc_away_25_col", "m_top_kingstone_lions_away_rll4_2017_col", "m_top_kingstone_lions_home_rll4_2017_col" } }, -- Swinton Lions
	[178] = { family = 97, kits = { "m_top_rams_rfl_home_26_col", "m_top_rams_rfl_away_26_col", "m_top_rams_rfl_home_25_col", "m_top_rams_rfl_away_25_col", "m_top_kingstone_rams_away_rll4_2017_col", "m_top_kingstone_rams_home_rll4_2017_col" } }, -- Dewsbury Rams
	[179] = { family = 98, kits = { "m_top_hornets_rfl_home_26_col", "m_top_hornets_rfl_away_26_col", "m_top_hornets_rfl_home_25_col", "m_top_hornets_rfl_away_25_col", "m_top_kingstone_hornets_away_rll4_2017_col", "m_top_kingstone_hornets_home_rll4_2017_col" } }, -- Rochdale Hornets
	[180] = { family = 99, kits = { "m_top_town_rfl_home_26_col", "m_top_town_rfl_away_26_col", "m_top_town_rfl_home_25_col", "m_top_town_rfl_away_25_col", "m_top_kingstone_1_workington_away_rll4_2017_col", "m_top_kingstone_1_workington_home_rll4_2017_col" } }, -- Workington Town
	[181] = { family = 100, kits = { "m_top_vikings_rfl_home_26_col", "m_top_vikings_rfl_away_26_col", "m_top_vikings_rfl_home_25_col", "m_top_vikings_rfl_away_25_col" } }, -- Goole Vikings
	[182] = { family = 101, kits = { "m_top_cougars_bfc_home_26_col", "m_top_cougars_bfc_away_26_col", "m_top_cougars_bfc_home_25_col", "m_top_cougars_bfc_away_25_col", "m_top_kingstone_1_cougars_away_rll4_2017_col", "m_top_kingstone_1_cougars_home_rll4_2017_col" } }, -- Keighley Cougars
	[183] = { family = 102, kits = { "m_top_thunder_bfc_home_26_col", "m_top_thunder_bfc_away_26_col", "m_top_thunder_bfc_home_25_col", "m_top_thunder_bfc_away_25_col", "m_top_kingstone_1_thunder_away_rll4_2017_col", "m_top_kingstone_1_thunder_home_rll4_2017_col" } }, -- Newcastle Thunder
	[184] = { family = 32, kits = {  } }, -- Brisbane Broncos Women
	[185] = { family = 33, kits = {  } }, -- Canberra Raiders Women
	[186] = { family = 34, kits = {  } }, -- Canterbury-Bankstown Bulldogs Women
	[187] = { family = 35, kits = {  } }, -- Cronulla Sharks Women
	[188] = { family = 36, kits = {  } }, -- Gold Coast Titans Women
	[189] = { family = 37, kits = {  } }, -- Newcastle Knights Women
	[190] = { family = 38, kits = {  } }, -- New Zealand Warriors Women
	[191] = { family = 39, kits = {  } }, -- North Queensland Cowboys Women
	[192] = { family = 40, kits = {  } }, -- Parramatta Eels Women
	[193] = { family = 41, kits = {  } }, -- St George Dragons Women
	[194] = { family = 42, kits = {  } }, -- Sydney Roosters Women
	[195] = { family = 43, kits = {  } }, -- Wests Tigers Women
	[196] = { family = 44, kits = { "f_top_raiders_wsl_home_25_col", "f_top_raiders_wsl_away_25_col" } }, -- Barrow Raiders Women
	[197] = { family = 197, kits = { "m_top_rovers_bfc_home_25_col", "m_top_rovers_bfc_away_25_col" } }, -- Featherstone Rovers Women
	[198] = { family = 45, kits = {  } }, -- Huddersfield Giants Women
	[199] = { family = 46, kits = {  } }, -- Leeds Rhinos Women
	[200] = { family = 47, kits = {  } }, -- Leigh Leopards Women
	[201] = { family = 48, kits = {  } }, -- St. Helens Saints Women
	[202] = { family = 50, kits = {  } }, -- Wigan Warriors Women
	[203] = { family = 51, kits = { "f_top_valkyrie_wsl_home_25_col", "f_top_valkyrie_wsl_away_25_col" } }, -- York Valkyrie Women
	[204] = { family = 204, kits = { "m_top_newZealand_rlwc_home_26_col", "m_top_newZealand_rlwc_away_26_col", "m_top_int_kiwi_home_rll4_2017_col", "m_top_int_kiwi_wc_home_rll4_2017_col" } }, -- New Zealand Kiwis
	[205] = { family = 205, kits = { "m_top_samoa_rlwc_home_26_col", "m_top_samoa_rlwc_away_26_col", "m_top_int_samoa_away_rll4_2017_col", "m_top_int_samoa_home_rll4_2017_col" } }, -- Toa Samoa
	[206] = { family = 206, kits = { "m_top_france_rlwc_home_26_col", "m_top_france_rlwc_away_26_col", "m_top_int_france_away_rll4_2017_col", "m_top_int_france_home_rll4_2017_col" } }, -- France Les Chanticleers
	[207] = { family = 207, kits = { "m_top_png_rlwc_home_26_col", "m_top_png_rlwc_away_26_col", "m_top_int_png_home_rll4_2017_col" } }, -- Papau New Guinea Kumuls
	[208] = { family = 208, kits = { "m_top_lebanon_rlwc_home_26_col", "m_top_lebanon_rlwc_away_26_col", "m_top_int_lebanon_away_rll4_2017_col", "m_top_int_lebanon_home_rll4_2017_col" } }, -- Lebanon Cedars
	[209] = { family = 209, kits = { "m_top_tonga_rlwc_home_26_col", "m_top_tonga_rlwc_away_26_col", "m_top_int_tonga_away_rll4_2017_col", "m_top_int_tonga_home_rll4_2017_col" } }, -- Tonga XIII
	[210] = { family = 210, kits = { "m_top_fiji_rlwc_home_26_col", "m_top_fiji_rlwc_away_26_col", "m_top_int_fiji_home_rll4_2017_col" } }, -- Fiji Bati
	[211] = { family = 211, kits = { "m_top_cookIslands_rlwc_home_26_col", "m_top_cookIslands_rlwc_away_26_col" } }, -- Cook Islands Aitu
	[212] = { family = 212, kits = {  } }, -- Australia Jillaroos
	[213] = { family = 213, kits = {  } }, -- England Lionesses
	[214] = { family = 214, kits = {  } }, -- Fetu Samoa
	[215] = { family = 215, kits = {  } }, -- Wales Dragons
	[216] = { family = 216, kits = {  } }, -- Fiji Bulikula
	[217] = { family = 206, kits = {  } }, -- France Les Chanticleers
	[218] = { family = 218, kits = {  } }, -- New Zealand Kiwi Ferns
	[219] = { family = 219, kits = {  } }, -- Papua New Guinea Orchids
}
-- crowd node count per stadium node file (lowercased path), for the Souths guy odds
local stadiumNodes = {
	["crowd/nodefiles/aucklandrugbystadium_crowdnodes.nodefile"] = 41619,
	["crowd/nodefiles/barrowrugbystadium_crowdnodes.nodefile"] = 7231,
	["crowd/nodefiles/bathurststadium_crowdnodes.nodefile"] = 4724,
	["crowd/nodefiles/batleystadium_crowdnodes.nodefile"] = 4664,
	["crowd/nodefiles/belmoresportsground_crowdnodes.nodefile"] = 8674,
	["crowd/nodefiles/birminghamrugbystadium_crowdnodes.nodefile"] = 17484,
	["crowd/nodefiles/blacktownsportingcomplex_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/bokarinastadium_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/bradfordrugbystadium_crowdnodes.nodefile"] = 13462,
	["crowd/nodefiles/brisbane_crowdnodes.nodefile"] = 44849,
	["crowd/nodefiles/brookvaleoval_crowdnodes.nodefile"] = 10374,
	["crowd/nodefiles/cairnsrugbypark_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/campbelltownsportsstadium_crowdnodes.nodefile"] = 10297,
	["crowd/nodefiles/canberrastadium_crowdnodes.nodefile"] = 23039,
	["crowd/nodefiles/castlefordrugbyground_crowdnodes.nodefile"] = 7958,
	["crowd/nodefiles/christchurch_rugbyleaguepark_crowdnodes.nodefile"] = 16925,
	["crowd/nodefiles/christchurch_tekahastadium_crowdnodes.nodefile"] = 23242,
	["crowd/nodefiles/colwynbaystadium_crowdnodes.nodefile"] = 12536,
	["crowd/nodefiles/cravenpark_crowdnodes.nodefile"] = 6902,
	["crowd/nodefiles/dewsburystadium_crowdnodes.nodefile"] = 4327,
	["crowd/nodefiles/doncasterstadium_crowdnodes.nodefile"] = 13924,
	["crowd/nodefiles/endeavourfield_crowdnodes.nodefile"] = 10313,
	["crowd/nodefiles/featherstonerugbystadium_crowdnodes.nodefile"] = 6572,
	["crowd/nodefiles/glenwillsportsstadium_crowdnodes.nodefile"] = 3907,
	["crowd/nodefiles/goolerugbyground_crowdnodes.nodefile"] = 1304,
	["crowd/nodefiles/halifaxstadium_crowdnodes.nodefile"] = 9505,
	["crowd/nodefiles/headingleyrugbystadium_crowdnodes.nodefile"] = 12766,
	["crowd/nodefiles/hilldickinsonstadium_crowdnodes.nodefile"] = 51359,
	["crowd/nodefiles/hullcitystadium_crowdnodes.nodefile"] = 31347,
	["crowd/nodefiles/hunterstadium_crowdnodes.nodefile"] = 19832,
	["crowd/nodefiles/industreegroupstadium_crowdnodes.nodefile"] = 17308,
	["crowd/nodefiles/ipswichreserve_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/keighleystadium_crowdnodes.nodefile"] = 2575,
	["crowd/nodefiles/kellyvillememorialpark_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/kirkleesstadium_crowdnodes.nodefile"] = 22112,
	["crowd/nodefiles/kirwanoval_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/kogarahoval_crowdnodes.nodefile"] = 10004,
	["crowd/nodefiles/langtreepark_crowdnodes.nodefile"] = 14985,
	["crowd/nodefiles/lasvegasstadium_crowdnodes.nodefile"] = 76083,
	["crowd/nodefiles/leichhardtoval_crowdnodes.nodefile"] = 9618,
	["crowd/nodefiles/leighsportsvillage_crowdnodes.nodefile"] = 9761,
	["crowd/nodefiles/mackaystadium_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/manchesterstadium_crowdnodes.nodefile"] = 59419,
	["crowd/nodefiles/manlywestoval_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/marraraoval_crowdnodes.nodefile"] = 5631,
	["crowd/nodefiles/marrickvillerugbypark_crowdnodes.nodefile"] = 7927,
	["crowd/nodefiles/melbournerectangularstadium_crowdnodes.nodefile"] = 25317,
	["crowd/nodefiles/miamirugbypark_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/moorepark_crowdnodes.nodefile"] = 35204,
	["crowd/nodefiles/mtsmartstadium_crowdnodes.nodefile"] = 22835,
	["crowd/nodefiles/northsydneyoval_crowdnodes.nodefile"] = 5633,
	["crowd/nodefiles/nundahrugbypark_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/oldhamstadium_crowdnodes.nodefile"] = 9535,
	["crowd/nodefiles/parramattastadium_crowdnodes.nodefile"] = 28788,
	["crowd/nodefiles/penrithreserve_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/penrithstadium_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/penrynrugbyground_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/perpignanstadium_crowdnodes.nodefile"] = 7099,
	["crowd/nodefiles/perthrectangularstadium_crowdnodes.nodefile"] = 17947,
	["crowd/nodefiles/perthstadium_crowdnodes.nodefile"] = 82191,
	["crowd/nodefiles/ploughlanestadium_crowdnodes.nodefile"] = 9628,
	["crowd/nodefiles/portmoresbystadium_crowdnodes.nodefile"] = 14181,
	["crowd/nodefiles/redcliffestadium_crowdnodes.nodefile"] = 8622,
	["crowd/nodefiles/redfernoval_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/robinastadium_crowdnodes.nodefile"] = 12644,
	["crowd/nodefiles/rochdalestadium_crowdnodes.nodefile"] = 10387,
	["crowd/nodefiles/rockhamptonrugbystadium_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/salerugbystadium_crowdnodes.nodefile"] = 2151,
	["crowd/nodefiles/salfordcommunitystadium_crowdnodes.nodefile"] = 9053,
	["crowd/nodefiles/scg_crowdnodes.nodefile"] = 37134,
	["crowd/nodefiles/sheffieldrugbystadium_crowdnodes.nodefile"] = 2076,
	["crowd/nodefiles/southleedsstadium_crowdnodes.nodefile"] = 2557,
	["crowd/nodefiles/stadeernestwallon_crowdnodes.nodefile"] = 16965,
	["crowd/nodefiles/stadium_crowdnodes.nodefile"] = 1192,
	["crowd/nodefiles/stadiumaustralia_crowdnodes.nodefile"] = 68092,
	["crowd/nodefiles/stonescornerrugbypark_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/swalwellrugbypark_crowdnodes.nodefile"] = 2202,
	["crowd/nodefiles/toowoombasportsground_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/townsvillestadium_crowdnodes.nodefile"] = 30868,
	["crowd/nodefiles/tweedheadswestsportscomplex_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/waikatostadium_crowdnodes.nodefile"] = 18045,
	["crowd/nodefiles/wakefieldstadium_crowdnodes.nodefile"] = 6429,
	["crowd/nodefiles/warringtonstadium_crowdnodes.nodefile"] = 10483,
	["crowd/nodefiles/wellingtonregionalstadium_crowdnodes.nodefile"] = 31736,
	["crowd/nodefiles/wembleystadium_crowdnodes.nodefile"] = 79702,
	["crowd/nodefiles/westendrugbypark_crowdnodes.nodefile"] = 43553,
	["crowd/nodefiles/whitehavenstadium_crowdnodes.nodefile"] = 4242,
	["crowd/nodefiles/widnesstadium_crowdnodes.nodefile"] = 11891,
	["crowd/nodefiles/wiganstadium_crowdnodes.nodefile"] = 24191,
	["crowd/nodefiles/wollongongshowground_crowdnodes.nodefile"] = 9712,
	["crowd/nodefiles/workingtonrugbystadium_crowdnodes.nodefile"] = 8272,
	["crowd/nodefiles/yorkstadium_crowdnodes.nodefile"] = 8182,
}
-- END GENERATED

local familyMembers = {}

for clubId, club in pairs(clubKits) do
	familyMembers[club.family] = familyMembers[club.family] or {}

	table.insert(familyMembers[club.family], clubId)
end

for _, members in pairs(familyMembers) do
	table.sort(members)
end

-- own home/away, then the rest of the family's home/away, then everything
-- else, so the MAX_COLS cap drops the least likely jerseys
local function buildJerseys(clubId)
	local club = clubKits[clubId]
	local tiers = { {}, {}, {}, {} }

	for index, texture in ipairs(club.kits) do
		table.insert(tiers[index <= 2 and 1 or 3], { texture = texture, weight = OWN_KIT_WEIGHTS[index] or 1 })
	end

	for _, memberId in ipairs(familyMembers[club.family]) do
		if memberId ~= clubId then
			for index, texture in ipairs(clubKits[memberId].kits) do
				-- a club with no crowd jerseys of its own weights the family's like its own
				local weight = #club.kits == 0 and OWN_KIT_WEIGHTS[index] or 1

				table.insert(tiers[index <= 2 and 2 or 4], { texture = texture, weight = weight })
			end
		end
	end

	local cols = {}
	local seen = {}

	for _, tier in ipairs(tiers) do
		for _, entry in ipairs(tier) do
			local texture = entry.texture

			if not seen[texture] then
				seen[texture] = true

				for _ = 1, entry.weight do
					if #cols < MAX_COLS then
						table.insert(cols, texture)
					end
				end
			end
		end
	end

	return cols
end

local jerseyVariants = items.m_crowd_clothing_tshirt.variants
local poloVariants = items.m_crowd_clothing_shortSleeve.variants
local merchVariants = {}
local visited = {}

for _, item in pairs(items) do
	local variants = item.variants

	if type(variants) == "table" and variants ~= jerseyVariants and not visited[variants] then
		visited[variants] = true

		for key in pairs(variants) do
			if type(key) == "string" and key:find("^teamID%d+$") then
				table.insert(merchVariants, variants)

				break
			end
		end
	end
end

local clubIds = {}

for clubId in pairs(clubKits) do
	table.insert(clubIds, clubId)
end

table.sort(clubIds)

for _, clubId in ipairs(clubIds) do
	local cols = buildJerseys(clubId)

	if #cols > 0 then
		jerseyVariants["teamID" .. clubId] = {
			cols = cols
		}
	end
end

-- clubs still without an entry borrow the family's (e.g. the women's clubs,
-- whose shipped entries use the men's crowd jerseys)
table.insert(merchVariants, jerseyVariants)

for _, clubId in ipairs(clubIds) do
	local tag = "teamID" .. clubId

	for _, variants in ipairs(merchVariants) do
		if variants[tag] == nil then
			for _, memberId in ipairs(familyMembers[clubKits[clubId].family]) do
				local borrowed = variants["teamID" .. memberId]

				if borrowed then
					variants[tag] = borrowed

					break
				end
			end
		end
	end
end

if SPRINKLE_TINTED_POLOS then
	for key, variant in pairs(poloVariants) do
		if type(key) == "string" and key:find("^teamID%d+$") and variant.cols[#variant.cols] ~= TINTED_POLOS[#TINTED_POLOS] then
			local cols = {}

			for _, texture in ipairs(variant.cols) do
				table.insert(cols, texture)
			end

			for _, texture in ipairs(TINTED_POLOS) do
				table.insert(cols, texture)
			end

			poloVariants[key] = {
				cols = cols
			}
		end
	end
end

-- Random Souths guy: whoever is playing, 1-5 fans somewhere in the crowd wear
-- a South Sydney jersey (any season or kit, picked per match).
--
-- The crowd can't be dressed fan by fan, only through weights, so this is a
-- rare top: a t-shirt item whose cols are SOUTHS_SLOTS Souths jerseys among
-- plain tees, added to the default male fans' tops with weight `bias`. Tops
-- biases are integers kept as a running byte total (rugbyleague1.exe
-- 0xbb1ef9), so the rarest pick is 1/255, and cols hold at most 16 - per fan
-- odds are bias/255 * slots/16, at least 1 in 4080. Both are sized per ground
-- (crowd_rugby.lua passes the node file) for SOUTHS_GUY_TARGET expected guys
-- at a full house; at grounds over ~25k nodes the floor gives more.
local SOUTHS_GUY_TARGET = 3
local SOUTHS_FAMILY = 8 -- South Sydney Rabbitohs 2025's family (with 2026 + legacy kits)
local MALE_FAN_SHARE = 0.5 -- of crowd nodes, roughly: default_male vs default_female
local DEFAULT_NODES = 30000
local SOUTHS_ITEM = "m_crowd_clothing_tshirt_southsguy"
local BIAS_TOTAL = 255

local function log(fmt, ...)
	pcall(function(...)
		local file = io.open("crowdteamkits_debug.txt", "a")

		file:write(os.date("%H:%M:%S "), string.format(fmt, ...), "\n")
		file:close()
	end, ...)
end

rawset(_G, "crowdTeamKitsLog", log)

local seed = (os.time() + math.floor(os.clock() * 1000)) % 2147483647

local function random(n)
	seed = (seed * 48271) % 2147483647

	return seed % n + 1
end

local southsJerseys = {}
local seenJersey = {}

for _, memberId in ipairs(familyMembers[SOUTHS_FAMILY] or {}) do
	for _, texture in ipairs(clubKits[memberId].kits) do
		if not seenJersey[texture] then
			seenJersey[texture] = true

			table.insert(southsJerseys, texture)
		end
	end
end

local tshirt = items.m_crowd_clothing_tshirt
local plainTees = tshirt.variants.base.cols
local nodeFile = rawget(_G, "crowdTeamKitsNodeFile")
local nodes = type(nodeFile) == "string" and stadiumNodes[nodeFile:lower()] or DEFAULT_NODES
local maleFans = nodes * MALE_FAN_SHARE

-- smallest bias that fits the target within 16 slots, else the 1-in-4080 floor
local bias, slots = 1, 1

for b = 1, 32 do
	local k = SOUTHS_GUY_TARGET / maleFans * BIAS_TOTAL * COLS_CAPACITY / b

	if k <= COLS_CAPACITY then
		bias, slots = b, math.max(1, math.floor(k + 0.5))

		break
	end
end

if #southsJerseys > 0 then
	local cols = {}

	for slot = 1, COLS_CAPACITY do
		if slot <= slots then
			table.insert(cols, southsJerseys[random(#southsJerseys)])
		else
			table.insert(cols, plainTees[(slot - slots - 1) % #plainTees + 1])
		end
	end

	items[SOUTHS_ITEM] = {
		model_path = tshirt.model_path,
		noExport = true,
		compatibilities = tshirt.compatibilities,
		variants = {
			base = {
				cols = cols,
				nrms = tshirt.variants.base.nrms,
				mats = tshirt.variants.base.mats
			}
		}
	}

	-- the shipped tops weights, kept across match loads (this module reruns
	-- every load but crowd_archetypes stays imported)
	local originals = rawget(_G, "crowdTeamKitsTopBiases") or {}

	rawset(_G, "crowdTeamKitsTopBiases", originals)

	for _, archetype in ipairs({ archetypes.active.default_male, archetypes.grand_final and archetypes.grand_final.default_male_gf }) do
		local tops = archetype and archetype.clothing_tops

		if tops then
			originals[archetype] = originals[archetype] or { items = { unpack(tops.items) }, biases = { unpack(tops.biases) } }

			local original = originals[archetype]
			local total = 0

			for _, weight in ipairs(original.biases) do
				total = total + weight
			end

			-- shipped weights rescaled to fill the byte total around the Souths item
			local newItems, newBiases, used = {}, {}, 0

			for index, item in ipairs(original.items) do
				local weight = index < #original.items and math.floor(original.biases[index] * (BIAS_TOTAL - bias) / total + 0.5) or BIAS_TOTAL - bias - used

				used = used + weight

				table.insert(newItems, item)
				table.insert(newBiases, weight)
			end

			table.insert(newItems, SOUTHS_ITEM)
			table.insert(newBiases, bias)

			tops.items, tops.biases = newItems, newBiases
		end
	end

	log("%s: %d nodes, Souths guy bias %d/%d x %d/%d slots -> %.1f expected at a full ground (%s)", tostring(nodeFile), nodes, bias, BIAS_TOTAL, slots, COLS_CAPACITY, maleFans * bias / BIAS_TOTAL * slots / COLS_CAPACITY, table.concat(cols, " ", 1, slots))
end
