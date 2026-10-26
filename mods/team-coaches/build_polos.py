#!/usr/bin/env python3
"""
build_polos.py - team-coloured coach polos for team-coaches.

The game ships one civilian polo model (top_polo01, in m_clothes/f_clothes)
with a blue and a grey texture. This bakes one texture per palette.json
colour from the grey one (fabric detail = luminance / its median, times the
colour; the dark neck label is kept), registers each as a uniformTop design
item (male guid, female guid + 100, same model as stock items 20001/20101)
and adds the textures to the compositor's table.

Usage (repo root, game closed for install/texsrc):
    python mods/team-coaches/build_polos.py bake                 # _build/team-coaches/*.png + sheet.png
    python mods/team-coaches/build_polos.py generate             # Lua overrides from decompiled/ + palette.json
    python mods/team-coaches/build_polos.py install [--replace] [--confirm]
    python mods/team-coaches/build_polos.py texsrc [--confirm]   # run AFTER rll4-legacy-kits texsrc

texsrc reads the LIVE characters/player/global.texsrc (so rll4-legacy-kits'
records stay), then restores and reinstalls the entry with the polo records
appended. rll4-legacy-kits' own texsrc rebuilds from stock, so rerun this
one after it.
"""

import argparse
import io
import json
import os
import struct
import sys

import numpy as np
from PIL import Image

MOD = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(MOD))
sys.path.insert(0, os.path.join(REPO, "tools"))
import pack  # noqa: E402

WORK = os.path.join(REPO, "_build", "team-coaches")
STOCK = os.path.join(REPO, "decompiled", "src", "script-game")
SRC = os.path.join(MOD, "src", "script-game")
TEXDIR = "characters/uniforms/textures"
GREY = "m_top_polo01_grey_col_2"   # 2048x2048 (the _1 level is 4096)
SIZES = {1: 2048, 2: 1024}         # same as the stock blue polo
TEMPLATE_GUID = {"m": 20001, "f": 20101}
TEXSRC_PATH = "characters/player/global.texsrc"


def load_palette():
    return json.load(open(os.path.join(MOD, "palette.json")))["colours"]


def tex_name(colour):
    return f"m_top_polo01_coach_{colour['name']}_col"


def _read_texture(blobset, logical):
    import add_entries
    import classify_entries as ce
    import extract_textures as et
    ce.load_index(blobset)
    data, count, hash_off, _ = pack.read_index(blobset)
    entry = add_entries.find_entry(data, count, hash_off, logical)
    if entry is None:
        raise SystemExit(f"{logical} not in the index")
    raw = ce.read_blob_full(blobset, entry)[0]
    return Image.open(io.BytesIO(et.parse_mini_txpk(raw)[1]))


def cmd_bake(args):
    os.makedirs(WORK, exist_ok=True)
    grey = _read_texture(args.blobset, f"{TEXDIR}/{GREY}.texture").convert("RGBA")
    px = np.asarray(grey).astype(np.float32)
    lum = px[..., :3].mean(-1)
    median = float(np.median(lum))
    label = lum < 0.6 * median           # dark neck label: keep as is
    shade = (lum / median)[..., None]
    previews = []
    for colour in load_palette():
        rgb = np.array(colour["rgb"], np.float32)
        out = px.copy()
        out[..., :3] = np.where(label[..., None], px[..., :3], np.clip(shade * rgb, 0, 255))
        img = Image.fromarray(out.round().astype(np.uint8), "RGBA")
        img.save(os.path.join(WORK, f"{colour['name']}.png"))
        previews.append((colour["name"], img.resize((128, 128), Image.LANCZOS)))
        print(f"baked {colour['name']}")
    sheet = Image.new("RGB", (128 * 8, 128 * ((len(previews) + 7) // 8)), (0, 0, 0))
    for i, (_, im) in enumerate(previews):
        sheet.paste(im.convert("RGB"), ((i % 8) * 128, (i // 8) * 128))
    sheet.save(os.path.join(WORK, "sheet.png"))
    print(f"median luminance {median:.1f}, label {label.mean() * 100:.1f}% of texels -> {WORK}")


def _dds_bgra(img):
    """Uncompressed 32-bit BGRA DDS, no mips, stored upside down like the
    stock uniform textures (same writer as rll4-legacy-kits)."""
    w, h = img.size
    header = bytearray(128)
    struct.pack_into("<4s7I", header, 0, b"DDS ", 124, 0x1007, h, w, 0, 1, 0)
    struct.pack_into("<2I4s5I", header, 76, 32, 0x41, b"\0\0\0\0", 32, 0xFF0000, 0xFF00, 0xFF, 0xFF000000)
    struct.pack_into("<I", header, 108, 0x1000)
    return bytes(header) + img.convert("RGBA").transpose(Image.FLIP_TOP_BOTTOM).tobytes("raw", "BGRA")


def cmd_install(args):
    import add_entries
    import club_icons
    for colour in load_palette():
        # baked images are read back as stored (extract keeps the game's
        # upside-down order), so flip once here to undo _dds_bgra's flip
        img = Image.open(os.path.join(WORK, f"{colour['name']}.png")).transpose(Image.FLIP_TOP_BOTTOM)
        for level, size in SIZES.items():
            im = img if img.width == size else img.resize((size, size), Image.LANCZOS)
            path = f"{TEXDIR}/{tex_name(colour)}_{level}.texture"
            blob, sizes = club_icons.make_blob(path, _dds_bgra(im))
            add_entries.add_entry(args.blobset, path, blob, sizes, f"team-coaches polo {colour['name']}",
                                  args.confirm, replace=args.replace)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


def _fnv1a32(text):
    h = 0x811C9DC5
    for c in text.lower().encode("utf-8"):
        h = ((h ^ c) * 0x01000193) & 0xFFFFFFFF
    return h


def cmd_texsrc(args):
    """Layout (see rll4-legacy-kits/build_kits.py): u32 count, then count x
    8 u32 [fnv1a32(path without extension), type, x, y, w, h, tex w, tex h]."""
    import add_entries
    import classify_entries as ce
    ce.load_index(args.blobset)
    data, count, hash_off, _ = pack.read_index(args.blobset)
    entry = add_entries.find_entry(data, count, hash_off, TEXSRC_PATH)
    raw = ce.read_blob_full(args.blobset, entry)[0]
    live_count = struct.unpack_from("<I", raw, 0)[0]
    if len(raw) != 4 + 32 * live_count:
        raise SystemExit(f"{TEXSRC_PATH} (entry {entry}) isn't the expected record table")
    known = set(struct.unpack_from(f"<{live_count * 8}I", raw, 4)[0::8])
    records = []
    for colour in load_palette():
        for level, size in SIZES.items():
            key = _fnv1a32(f"{TEXDIR}/{tex_name(colour)}_{level}")
            if key not in known:
                records.append(struct.pack("<8I", key, 0, 0, 0, size, size, size, size))
    print(f"{TEXSRC_PATH} (entry {entry}): {live_count} live records, {len(records)} to add")
    if not records:
        return
    os.makedirs(WORK, exist_ok=True)
    out = os.path.join(WORK, "global.texsrc")
    with open(out, "wb") as f:
        f.write(struct.pack("<I", live_count + len(records)) + raw[4:] + b"".join(records))
    if not args.confirm:
        print("dry run - pass --confirm to install (close the game first)")
        return
    if os.path.exists(pack.backup_meta_path(entry)):
        pack.do_restore(args.blobset, entry)
    pack.do_install(args.blobset, entry, out, True)
    print(f"installed entry {entry} (undo: python tools/pack.py restore --entry {entry})")


# --------------------------------------------------------------------------
# Lua generation

BLOCK_START = "-- team-coaches: generated by mods/team-coaches/build_polos.py"


def _write_with_block(rel, block):
    stock = open(os.path.join(STOCK, rel), encoding="utf-8-sig").read().rstrip() + "\n"
    dst = os.path.join(SRC, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, "w", encoding="utf-8", newline="") as f:
        f.write("﻿" + stock + "\n" + block)
    print("wrote", dst)


def _patch(rel, edits, append=""):
    text = open(os.path.join(STOCK, rel), encoding="utf-8").read()
    for old, new in edits:
        n = text.count(old)
        if n != 1:
            raise SystemExit(f"{rel}: expected 1 match, got {n}:\n{old}")
        text = text.replace(old, new)
    dst = os.path.join(SRC, rel)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, "w", encoding="utf-8", newline="") as f:
        f.write(text.rstrip() + "\n" + append)
    print("wrote", dst)


IDENTITY_PICKER = '''
-- team-coaches: coach picker opened from the Identity "Coach" row. Reuses the
-- maintained referee list (as coach-editor does) filtered to coaches, previews
-- the highlighted coach in this club's polo, and saves the pick to the club.
local var_tc_list = academy_referee_list.AcademyRefereeListState

Class("TeamCoachesPickerState", var_tc_list)

function TeamCoachesPickerState.enter(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8)
	arg_tc_0.goBackFactory = arg_tc_8
	arg_tc_0.club = VERIFY(arg_tc_7.club)

	local var_tc_0 = native.CRefereeSearchOptions()

	var_tc_0.mustBeType = native.CNpcType.Coach

	local var_tc_1 = native.CRefereeSearchOptions()

	var_tc_1:set(var_tc_0)

	local var_tc_2 = coach_helper.getClubCoach(arg_tc_5, arg_tc_0.club)

	arg_tc_5:toggleLockerRoomVisibility(true)
	var_tc_list.enter(arg_tc_0, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6.partyMember, var_tc_2 and var_tc_2.id or nil, {
		sortAllowed = true,
		filterAllowed = false,
		exitOnSelection = true,
		backInputAllowed = true,
		playerModelConfig = {
			uniformSet = true
		},
		columns = academy_config.RefereeColumns,
		columnInitialSort = academy_config.RefereeColumnsInitialSort,
		itemParams = {},
		boxTitle = coach_helper.localiseOr("Coach", "Coach"),
		listTitle = coach_helper.localiseOr("Coach", "Coach"),
		searchOptions = var_tc_0,
		searchOptionsReset = var_tc_1
	})
end

function TeamCoachesPickerState.delayedRefreshPlayerModel(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5)
	if not arg_tc_5.playerModelConfig then
		return
	end

	if arg_tc_4 then
		if arg_tc_4 ~= arg_tc_0.pmShowingReferee then
			if arg_tc_4 == arg_tc_0.pmWantingReferee then
				if arg_tc_2 >= arg_tc_0.pmRefreshAt then
					local var_tc_3 = coach_helper.makePoloUniform(arg_tc_4, arg_tc_0.club.identity.primaryRGBColour)

					arg_tc_1:playerModelUpdate(1, {
						refresh = true,
						draw = true,
						coach = {
							visual = arg_tc_4.visual,
							identity = arg_tc_4.identity,
							uniform = var_tc_3
						}
					})

					arg_tc_0.pmShowingReferee = arg_tc_4
					arg_tc_0.pmWantingReferee = nil
					arg_tc_0.pmRefreshAt = nil
				end
			else
				arg_tc_0.pmWantingReferee = arg_tc_4
				arg_tc_0.pmRefreshAt = arg_tc_2 + 0.4
			end
		end
	else
		arg_tc_1:playerModelUpdate(1, {
			draw = false
		})

		arg_tc_0.pmShowingReferee = nil
		arg_tc_0.pmWantingReferee = nil
		arg_tc_0.pmRefreshAt = nil
	end
end

function TeamCoachesPickerState.update(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8, arg_tc_9)
	local var_tc_4, var_tc_5, var_tc_6, var_tc_7 = var_tc_list.update(arg_tc_0, arg_tc_2, arg_tc_3, arg_tc_4, arg_tc_5, arg_tc_6, arg_tc_7, arg_tc_8.partyMember)

	if var_tc_4 then
		if var_tc_7 then
			local var_tc_8 = arg_tc_9.club
			local var_tc_9 = var_tc_8.coachId

			var_tc_8:setCoachId(var_tc_7.id)
			pcall(function()
				coach_helper.sidelineLog("academy: club %s (id %s) coachId %s -> %s (%s), reads back %s", tostring(var_tc_8.fullName), tostring(var_tc_8.id), tostring(var_tc_9), tostring(var_tc_7.id), coach_helper.getCoachName(var_tc_7), tostring(var_tc_8.coachId))
			end)

			-- Only user-created clubs are saved; a built-in club reloads from the
			-- disc database next launch. Like the stock AcademyCoachAssignClubState,
			-- make the club's user-created version first and set the coach on it.
			local var_tc_10, var_tc_11 = pcall(function()
				local var_tc_12 = arg_tc_6:getClubManager()
				local var_tc_13 = var_tc_8.id
				local var_tc_14 = var_tc_12.userCreated:getClub(var_tc_13)
				local var_tc_15 = "existing"

				if not var_tc_14 then
					local var_tc_16 = var_tc_12.onDisc:getClub(var_tc_13)

					if var_tc_16 then
						local var_tc_17 = native.CClub()

						var_tc_17:set(var_tc_16)

						var_tc_17.createdAt = native.UTCTime.now()

						var_tc_12.userCreated:addClub(var_tc_17, var_tc_13)

						var_tc_14 = var_tc_12:getClub(var_tc_13)
						var_tc_15 = "created"
					end
				end

				if var_tc_14 then
					var_tc_14:setCoachId(var_tc_7.id)
				end

				return string.format("%s user-created copy, coachId %s", var_tc_14 and var_tc_15 or "no", tostring(var_tc_14 and var_tc_14.coachId))
			end)

			coach_helper.sidelineLog("academy: persist: %s", tostring(var_tc_11))

			-- official clubs drop coachId when the editor reloads them, so the
			-- mod also keeps its own club -> coach record (read by Identity and
			-- by the sideline code in matches)
			coach_helper.setAssignedCoachId(coach_helper.tryGetField(var_tc_8, "academyId") or var_tc_8.id, var_tc_7.id, coach_helper.getCoachName(var_tc_7))

			var_tc_8.sharing.hasUnsharedModifications = true

			arg_tc_9.setDirty()
			arg_tc_9.saveIfDirty(arg_tc_2)
		end

		arg_tc_1:changeState(ClubViewIdentityState(), arg_tc_2, arg_tc_3, arg_tc_5, arg_tc_6, arg_tc_8, arg_tc_9, arg_tc_0.__proto)
	end
end

function TeamCoachesPickerState.exit(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4)
	arg_tc_4:toggleLockerRoomVisibility(false)
	var_tc_list.exit(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3, arg_tc_4)
end
'''


def generate_identity():
    _patch("app/club/club_viewstate_identity_state.lua", [
        ('import("core.foundation.func")\n',
         'import("core.foundation.func")\n'
         'import("app.academy.academy_referee_list")\n'
         'import("design.academy_config")\n'
         'import("game.coach.coach_helper")\n'),
        ("local function var_0_25(arg_38_0, arg_38_1, arg_38_2)\n",
         """-- team-coaches: "Coach: <name>" row; pressing it opens TeamCoachesPickerState
local function teamCoachesCoachRow(arg_tc_0, arg_tc_1)
	local var_tc_0, var_tc_2 = coach_helper.getClubCoach(arg_tc_0, arg_tc_1.club)
	local var_tc_1 = var_tc_0 and coach_helper.getCoachName(var_tc_0) or var_tc_2 and string.format("#%s (not found)", tostring(var_tc_2)) or coach_helper.localiseOr("None", "None")

	return optionmenu_aide.createButton(string.format("%s: %s", coach_helper.localiseOr("Coach", "Coach"), var_tc_1), {
		teamCoachesButton = true,
		editableGetFn = var_0_8,
		examinationFunction = function()
			return false
		end
	})
end

local function var_0_25(arg_38_0, arg_38_1, arg_38_2)
"""),
        ("	table.insert(var_38_0, var_0_19(arg_38_0, arg_38_1))\n",
         "	table.insert(var_38_0, var_0_19(arg_38_0, arg_38_1))\n\n"
         "	if GAME_RUGBY then\n"
         "		table.insert(var_38_0, teamCoachesCoachRow(arg_38_1, arg_38_2))\n"
         "	end\n"),
        ("	arg_41_0.goBackFactory = arg_41_8\n",
         "	arg_41_0.goBackFactory = arg_41_7.teamCoachesIdentityGoBack or arg_41_8\n"
         "	arg_41_7.teamCoachesIdentityGoBack = nil\n\n"
         "	pcall(function()\n"
         "		local var_tc_0 = arg_41_7.club\n\n"
         "		local var_tc_1 = coach_helper.tryGetField(var_tc_0, \"academyId\")\n\n"
         "		coach_helper.sidelineLog(\"academy: Identity opened for %s (id %s, academyId %s, onDisc %s, canEdit %s), coachId %s, assignment %s\", tostring(var_tc_0.fullName), tostring(var_tc_0.id), tostring(var_tc_1), tostring(arg_41_7.isOnDiscClub), tostring(arg_41_7.canEdit), tostring(var_tc_0.coachId), tostring(coach_helper.getAssignedCoachId(var_tc_1 or var_tc_0.id)))\n"
         "	end)\n"),
        ("	if var_46_1 then\n		arg_46_6:clearNotification()\n",
         """	if var_46_4 and var_46_4.teamCoachesButton then
		arg_46_6:playSound("Select")
		arg_46_6:clearNotification()

		arg_46_9.teamCoachesIdentityGoBack = arg_46_0.goBackFactory

		arg_46_1:changeState(TeamCoachesPickerState(), arg_46_2, arg_46_3, arg_46_5, arg_46_6, arg_46_8, arg_46_9, arg_46_0.__proto)

		return
	end

	if var_46_1 then
		arg_46_6:clearNotification()
"""),
    ], IDENTITY_PICKER)


CHEERLEADER_WRAP = '''
-- team-coaches: every reposition wipe calls positionCheerleaders, so the
-- sideline coaches are placed (and re-skinned once per match) right after it.
import("game.coach.coach_helper")

local var_tc_positionCheerleaders = positionCheerleaders

function positionCheerleaders(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3)
	var_tc_positionCheerleaders(arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3)

	local var_tc_0, var_tc_1 = pcall(coach_helper.positionSidelineCoaches, arg_tc_0, arg_tc_1, arg_tc_2, arg_tc_3)

	if not var_tc_0 then
		coach_helper.sidelineLog("positionSidelineCoaches failed: %s", tostring(var_tc_1))
	end
end
'''


REACTION_CUTSCENES = '''
-- team-coaches: coach reaction cutscenes (played by CoachReactionRuleState).
-- Copies of the conversion-reaction close-ups with the actor slot retyped to
-- "npc" (the sideline coaches are pooled NPCObjects) and the kicking tee
-- removed. Origin stays PrimaryActor, so they play where the coach stands.
pcall(function()
	local rawtypeOf = rawtype or type
	local function copyData(value)
		if rawtypeOf(value) ~= "table" then
			return value
		end

		local result = {}

		for key, item in pairs(value) do
			result[key] = copyData(item)
		end

		return result
	end

	for name, source in pairs({
		teamcoaches_happy_01 = "rl1_conversion_very_positive_01",
		teamcoaches_happy_02 = "rl1_conversion_very_positive_02",
		teamcoaches_gutted_01 = "rl1_conversion_negative_01",
		teamcoaches_gutted_02 = "rl1_conversion_negative_02",
		teamcoaches_gutted_03 = "rl1_conversion_negative_03"
	}) do
		local base = CutsceneData[source]

		if base and not CutsceneData[name] then
			local data = copyData(base)

			data.props = nil

			for _, actor in ipairs(data.actors or {}) do
				actor.filter = {
					actorType = "npc"
				}
			end

			CutsceneData[name] = data
		end
	end
end)
'''

def cmd_generate(args):
    generate_identity()
    _patch("game/cheerleader/cheerleader_helper.lua", [], CHEERLEADER_WRAP)
    _patch("intermediatelua/cutscenes/data/cs_conversion_data.lua", [], REACTION_CUTSCENES)
    _patch("rules/cutscenes/cheerleadercelebrate_rulestate.lua", [],
           "\n" + open(os.path.join(MOD, "reaction_rulestate_block.lua"), encoding="utf-8").read())
    palette = load_palette()
    items = "\n".join(
        f'\t\t{{ {c["guid"]}, {c["guid"] + 100}, "{tex_name(c)}" }}, -- {c["name"]}' for c in palette)
    _write_with_block("design/characters/blendshapes.lua", f"""{BLOCK_START} (palette.json).
-- Registers the coach polo design items. assetmap imports this file right after
-- assetmapitems and before the native asset map reads ItemMaps, the same window
-- rll4-legacy-kits uses from jigglyjointsconfig.lua.
do
	local ItemMaps = import("design.characters.assetmapitems").ItemMaps
	local map = ItemMaps.uniformTop
	local lookup = map.item_setup_lookup
	local colMap = ItemMaps.uniformTop_col

	local function addPolo(templateGuid, guid, colTexture)
		local template = lookup[templateGuid]

		if template == nil or lookup[guid] ~= nil then
			return
		end

		local item = {{}}

		for key, value in pairs(template) do
			item[key] = value
		end

		item.guid = guid
		item.colTexture = colTexture

		table.insert(map.item_setup, item)

		lookup[guid] = item

		if colMap.item_setup_lookup[colTexture] == nil then
			local entry = {{
				name = colTexture,
				blend = colMap.blend
			}}

			table.insert(colMap.item_setup, entry)

			colMap.item_setup_lookup[colTexture] = entry
		end
	end

	for _, polo in ipairs({{
{items}
	}}) do
		addPolo({TEMPLATE_GUID["m"]}, polo[1], polo[3])
		addPolo({TEMPLATE_GUID["f"]}, polo[2], polo[3])
	end
end
""")
    rows = "\n".join(
        f'\t{{ guid = {c["guid"]}, r = {c["rgb"][0]}, g = {c["rgb"][1]}, b = {c["rgb"][2]}, name = "{c["name"]}" }},'
        for c in palette)
    helper = open(os.path.join(MOD, "coach_helper_block.lua"), encoding="utf-8").read()
    _write_with_block("game/coach/coach_helper.lua",
                      f"{BLOCK_START} (palette.json + coach_helper_block.lua).\n"
                      f"PoloPalette = {{\n{rows}\n}}\n\n{helper}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--blobset", default=pack.BLOBSET_PATH)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("bake").set_defaults(func=cmd_bake)
    sub.add_parser("generate").set_defaults(func=cmd_generate)
    p = sub.add_parser("install")
    p.add_argument("--replace", action="store_true")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_install)
    p = sub.add_parser("texsrc")
    p.add_argument("--confirm", action="store_true")
    p.set_defaults(func=cmd_texsrc)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
