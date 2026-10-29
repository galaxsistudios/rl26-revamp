local function var_0_0(...)
	local var_1_0 = {}
	local var_1_1 = 1

	for iter_1_0, iter_1_1 in ipairs({
		...
	}) do
		for iter_1_2, iter_1_3 in ipairs(iter_1_1) do
			var_1_0[var_1_1] = iter_1_3
			var_1_1 = var_1_1 + 1
		end
	end

	return var_1_0
end

local var_0_1 = {
	"nrl_broncos",
	"nrl_bulldogs",
	"nrl_cowboys",
	"nrl_dragons",
	"nrl_eels",
	"nrl_knights",
	"nrl_panthers",
	"nrl_rabbitohs",
	"nrl_raiders",
	"nrl_roosters",
	"nrl_seaeagles",
	"nrl_sharks",
	"nrl_storm",
	"nrl_tigers",
	"nrl_titans",
	"nrl_warriors",
	"nrl_dolphins"
}
local var_0_2 = {
	"sl_castleford",
	"sl_catalans",
	"sl_huddersfield",
	"sl_hullfc",
	"sl_hullkr",
	"sl_leeds",
	"sl_leigh",
	"sl_salford",
	"sl_sthelens",
	"sl_wakefield",
	"sl_warrington",
	"sl_widnes",
	"sl_wigan"
}
local var_0_3 = {
	"slw_barrow",
	"slw_huddersfield",
	"slw_leeds",
	"slw_leigh",
	"slw_leigh",
	"slw_sthelens",
	"slw_valkyrie",
	"slw_warrington",
	"slw_wigan"
}
local var_0_4 = {
	"nsw_blackhawks",
	"nsw_mounties",
	"nsw_seaeagles",
	"nsw_magpies"
}
local var_0_5 = {
	"qld_bears",
	"qld_blackhawks",
	"qld_capras",
	"qld_cutters",
	"qld_devils",
	"qld_dolphins",
	"qld_falcons",
	"qld_gullsmanly",
	"qld_hunters",
	"qld_jets",
	"qld_magpies",
	"qld_pride",
	"qld_seagulls",
	"qld_tigers",
	"qld_tigers",
	"qld_clydesdales"
}
local var_0_6 = {
	"king_broncos",
	"king_bulldogs",
	"king_bulls",
	"king_centurions",
	"king_eagles",
	"king_feather",
	"king_halifax",
	"king_hullkingston",
	"king_hornets",
	"king_oldham",
	"king_olympique",
	"king_lions",
	"king_rams",
	"king1_vikings"
}
local var_0_7 = {
	"king1_allgolds",
	"king1_bears",
	"king1_cougers",
	"king1_crusaders",
	"king1_doncaster",
	"king1_hawks",
	"king1_ironmen",
	"king1_knights",
	"king1_oxford",
	"king1_raiders",
	"king1_skolars",
	"king1_stags",
	"king1_thunder",
	"king1_whitehaven",
	"king1_workington",
	"king1_hurricanes"
}
local var_0_8 = {
	"rep_australia",
	"rep_nz",
	"rep_england",
	"rep_belguim",
	"rep_canada",
	"rep_cookislands",
	"rep_czechrep",
	"rep_denmark",
	"rep_fiji",
	"rep_france",
	"rep_germany",
	"rep_greece",
	"rep_holland",
	"rep_hungary",
	"rep_ireland",
	"rep_italy",
	"rep_jamaica",
	"rep_latvia",
	"rep_lebanon",
	"rep_malta",
	"rep_morocco",
	"rep_norway",
	"rep_png",
	"rep_samoa",
	"rep_scotland",
	"rep_serbia",
	"rep_southafrica",
	"rep_spain",
	"rep_sweden",
	"rep_tonga",
	"rep_ukraine",
	"rep_usa",
	"rep_wales"
}
local var_0_9 = {
	"rep_australia_2",
	"rep_nz_2",
	"rep_england_2",
	"rep_cookislands_2",
	"rep_australia_w",
	"rep_fiji_w",
	"rep_nz_w",
	"rep_png_w"
}
local var_0_10 = {
	"aus_jillaroos",
	"canada_ravens",
	"cookislands",
	"nz_ferns",
	"png_orchids",
	"rep_fiji_2",
	"rep_france_2",
	"rep_ireland_2",
	"rep_italy_2",
	"rep_lebanon_2",
	"rep_nz_3",
	"rep_png_2",
	"rep_samoa_2",
	"rep_scotland_2",
	"rep_tonga_2",
	"rep_usa_2",
	"rep_wales_2"
}
local var_0_11 = {
	"rep_nsw",
	"rep_qld",
	"soow_nsw",
	"soow_qld"
}
local var_0_12 = {
	"rep_allstars",
	"rep_indigenous",
	"rep_city",
	"rep_country",
	"maori"
}
local var_0_13 = {
	"rep_bigant_male",
	"rep_bigant_female"
}
local var_0_14 = {
	"bigant"
}
local var_0_15 = {
	"soo_nsw",
	"soo_qld"
}
local var_0_16 = {
	"custom"
}
local var_0_17 = {
	"proteam",
	"nsw_bears",
	"nsw_jets",
	"nsw_westernsuburbs",
	"halloween_1",
	"halloween_2",
	"halloween_3",
	"halloween_4",
	"halloween_5",
	"halloween_6",
	"halloween_7",
	"halloween_8",
	"halloween_9",
	"halloween_10",
	"halloween_11",
	"xmas_1",
	"xmas_2",
	"xmas_3",
	"xmas_4",
	"xmas_5",
	"xmas_6",
	"xmas_7",
	"xmas_8",
	"xmas_9",
	"xmas_10",
	"xmas_11",
	"val_1",
	"val_2",
	"val_3",
	"val_4",
	"val_5",
	"val_6",
	"val_7",
	"val_8",
	"val_9",
	"val_10",
	"val_11",
	"val_12",
	"val_13",
	"easter_1",
	"easter_2",
	"easter_3",
	"easter_4",
	"easter_5",
	"easter_6",
	"easter_7",
	"easter_8",
	"easter_9",
	"easter_10",
	"easter_10",
	"HMStretch_Shard",
	"S10_emblem",
	"anzac_1",
	"anzac_2",
	"anzac_3",
	"anzac_4",
	"anzac_5"
}
local var_0_18 = {
	"light_red",
	"dark_red",
	"yellow",
	"gold",
	"orange",
	"light_blue",
	"dark_blue",
	"light_green",
	"dark_green",
	"plum",
	"indigo",
	"purple"
}
local var_0_19 = {}

for iter_0_0 = 1, 118 do
	table.insert(var_0_19, string.format("cus_%02d", iter_0_0))
end

-- new-club-icons: emblems added by tools/club_icons.py (15 appended blobset
-- entries each). Kept last in every list so no shipped icon changes position.
-- Each also needs a ClubIconColourSetMap entry in icons.lua.
local ModClubIcons = {
	"nrl_bears",
	"nrl_chiefs",
	-- classic (pre-rebrand) emblems, see classic_logos.py
	"nrl_broncos_classic_1",
	"nrl_broncos_classic_2",
	"nrl_raiders_classic_1",
	"nrl_raiders_classic_2",
	"nrl_bulldogs_classic_1",
	"nrl_bulldogs_classic_2",
	"nrl_sharks_classic_1",
	"nrl_titans_classic_1",
	"nrl_seaeagles_classic_1",
	"nrl_seaeagles_classic_2",
	"nrl_storm_classic_1",
	"nrl_warriors_classic_1",
	"nrl_warriors_classic_2",
	"nrl_knights_classic_1",
	"nrl_knights_classic_2",
	"nrl_cowboys_classic_1",
	"nrl_cowboys_classic_2",
	"nrl_eels_classic_1",
	"nrl_eels_classic_2",
	"nrl_panthers_classic_1",
	"nrl_panthers_classic_2",
	"nrl_rabbitohs_classic_1",
	"nrl_roosters_classic_1",
	"nrl_tigers_classic_1"
}

CrowdSets = var_0_0(var_0_1, var_0_2, var_0_15, var_0_16)
ClubIconsPreload = var_0_0(var_0_1, var_0_2, var_0_3, var_0_4, var_0_5, var_0_6, var_0_7, var_0_8, var_0_9, var_0_11, var_0_12, var_0_13, var_0_16, var_0_19, var_0_10, var_0_17, ModClubIcons)
ClubIcons = var_0_0(var_0_1, var_0_2, var_0_3, var_0_4, var_0_5, var_0_6, var_0_7, var_0_8, var_0_9, var_0_10, var_0_11, var_0_12, var_0_13, var_0_16, var_0_19, var_0_15, ModClubIcons)
ClubIconsNoDlc = var_0_0(var_0_1, var_0_2, var_0_3, var_0_4, var_0_5, var_0_6, var_0_7, var_0_8, var_0_11, var_0_12, var_0_13, var_0_16, var_0_19, ModClubIcons)
ColourSets = var_0_0(var_0_1, var_0_2, var_0_14, var_0_16, var_0_18)
