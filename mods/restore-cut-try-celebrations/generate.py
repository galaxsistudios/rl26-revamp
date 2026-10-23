#!/usr/bin/env python3
"""
generate.py - Rebuilds this mod's Lua overrides from the stock decompiled sources.

Run from the repo root:  python mods\\restore-cut-try-celebrations\\generate.py
(build.py skips *.py files, so this script never ends up in the bundle.)

Writes, under src/script-game/:
  intermediatelua/cutscenes/data/cs_try_celebrate_data.lua     + restored legacy + Storm cutscenes
  intermediatelua/cutscenes/data/cutscenegroupdata_config.lua  + restored legacy cutscenes in groups
  rules/cutscenes/trycelebrate_rulestate.lua                   + Storm players' own celebration
  game/camera/animated_camera.lua                              + optional per-camera motion
"""
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(ROOT))
STOCK = os.path.join(REPO, "decompiled", "src", "script-game")
OUT = os.path.join(ROOT, "src", "script-game")

DATA = "intermediatelua/cutscenes/data/cs_try_celebrate_data.lua"
GROUPS = "intermediatelua/cutscenes/data/cutscenegroupdata_config.lua"
RULESTATE = "rules/cutscenes/trycelebrate_rulestate.lua"
CAMERA = "game/camera/animated_camera.lua"

# Legacy animsets that are loaded but never had a cutscene. Clip names follow
# rl1_cs_trycelebrate_mr_bow_arrow_01, the one cutscene still using a legacy animset.
# (cutscene name, animset, clip base, actor count)
LEGACY = [
    ("cs_trycelebrate_tapshoulder_01", "cutsceneTryCelebrateTapshoulder01", "cs_trycelebrate_tapshoulder_01", 2),
    ("cs_trycelebrate_scruffhair_02", "cutsceneTryCelebrateScruffleHair02", "cs_trycelebrate_scruffhair_02", 2),
    ("cs_tryneutral_tapchest_01", "cutsceneTryNeutralTapchest01", "cs_tryneutral_tapchest_01", 1),
]
LEGACY_CAMERAS = 4
LEGACY_SYNC_FRAME = 75
LEGACY_WEIGHT = 1000  # test value: stock weights are 0.5-1 (Mr Bow & Arrow is 10)
LEGACY_GROUPS = ["TryCelebrateStanding", "TryCelebrateStanding_low", "TryCelebrateStanding_high"]

# Per-player clips from the unused Storm promo shoot (animset cutsceneStormPromo).
# The stock rl1_storm_promo_* cutscenes are studio shots (world origin, academy lighting),
# so these get match-style definitions anchored on the scorer instead.
# (full name as in the player database, clip, camera count)
STORM = [
    ("Jack Howarth", "jack_howarth_celebration", 1),
    ("Sua Fa'alogo", "sua_faalogo_celebration", 1),
    ("Harry Grant", "harry_grant_celebration", 1),
    ("Cameron Munster", "cameron_munster_celebration", 1),
    ("Jahrome Hughes", "jahrome_hughes_celebration", 1),
    ("Nick Meaney", "nick_meaney_celebration", 1),
    ("Josh King", "josh_king_celebration", 1),
    ("Tyran Wishart", "tyran_wishart_celebration", 1),
    ("Moses Leo", "moses_leo_celebration", 1),
    ("Shawn Blore", "shawn_blore_celebration", 1),
    ("Will Warbrick", "will_warbrick_celebration", 1),
    ("Alec MacDonald", "alec_macdonald_celebration", 1),
    ("Xavier Coates", "xavier_coates_celebration", 1),
    ("Joe Chan", "joe_chan_celebration", 1),
    ("Tui Kamikamica", "tui_kamikamica_celebration", 2),
]
STORM_CHANCE_PERCENT = 50  # how often a Storm player picks his own celebration first
STORM_POOL_WEIGHT = 1000  # test value: weight of each Storm clip in everyone's standing-try groups
STORM_GROUPS = LEGACY_GROUPS

# The Storm promo cameras are locked off (studio tripod shots). These fields are read by
# the patched game/camera/animated_camera.lua; stock cameras don't set them.
#   motionPushInFovScale  FOV multiplier reached at the end of the clip (< 1 zooms in)
#   motionDollyDistance   metres the camera drifts forward along its view over the clip
#   motionSway            metres of slow handheld-style drift
STORM_CAMERA_MOTION = {
    "motionPushInFovScale": 0.82,
    "motionDollyDistance": 0.6,
    "motionSway": 0.04,
}
LEGACY_CAMERA_MOTION = {}


def name_key(full_name):
    return "".join(c for c in full_name.lower() if "a" <= c <= "z")


def storm_cutscene_name(clip):
    return "rl1_try_" + clip


def actor(clip, index, sync_frame):
    if index == 1:
        return f'''			{{
				animName = "{clip}",
				name = "primary",
				syncOnFrame = {sync_frame},
				optional = true,
				filter = {{
					actorType = "player"
				}}
			}}'''
    return f'''			{{
				animName = "{clip}",
				optional = true,
				syncOnFrame = {sync_frame},
				syncTo = "primary",
				filter = {{
					actorType = "player"
				}}
			}}'''


def camera(clip, index, motion):
    motion_lines = "".join(f"\t\t\t\t{k} = {v},\n" for k, v in motion.items())
    return f'''			{{
				animName = "{clip}",
				name = "cs_camera{index:02d}",
				moveRelativeToActorLabel = "primary",
{motion_lines}				near = 0.1,
				jointName = "cs_camera{index:02d}",
				fovScaleShortestPlayer = 0.8,
				fovScaleTallestPlayer = 1,
				dof = {{
					{{
						intensity = 1,
						nearIntensity = 1,
						focusDistance = "auto",
						frame = 0,
						aperture = 4,
						targetActor = "primary",
						autoDofJoints = {{
							"hips"
						}}
					}}
				}}
			}}'''


def cut(index):
    return f'''			{{
				{{
					frame = 0,
					transition = "cut",
					camera = "cs_camera{index:02d}"
				}}
			}}'''


CROWD_EVENT = '''			{
				frame = 1,
				name = "CrowdEvent",
				group = "Intro",
				animations = {
					{
						forceSnap = true,
						tags = "TAGS_ALL",
						animGroup = native.ECrowdAnimGroup.excitement_level_3
					}
				}
			}'''

# Same stadium flame bursts as rl1_cs_trycelebrate_mr_bow_arrow_01.
FLAME_EVENTS = [
    f'''			{{
				frame = {frame},
				name = "ParticleEvent",
				particleEvent = "f01_std_flame_burst02_{(i % 4) + 1:02d}"
			}}'''
    for i, frame in enumerate(range(15, 126, 10))
]


def cutscene(name, animset, actor_clips, camera_clip, cameras, sync_frame, motion):
    actors = ",\n".join(actor(c, i, sync_frame) for i, c in enumerate(actor_clips, 1))
    cams = ",\n".join(camera(camera_clip, i, motion) for i in range(1, cameras + 1))
    events = ",\n".join([CROWD_EVENT] + FLAME_EVENTS)
    cuts = ",\n".join(cut(i) for i in range(1, cameras + 1))
    return f'''	{name} = {{
		povCameraAllowed = false,
		animsetName = "{animset}",
		checkCameraBoundary = true,
		cutsceneOrigin = var_0_0,
		clampScale = native.CRange(0.97, 1.03),
		actors = {{
{actors}
		}},
		cameras = {{
{cams}
		}},
		playbackEvents = {{
{events}
		}},
		cuts = {{
{cuts}
		}}
	}}'''


def read(rel):
    with open(os.path.join(STOCK, rel), encoding="utf-8-sig", newline="") as f:
        return f.read()


def write(rel, text):
    path = os.path.join(OUT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        f.write(text)
    print("wrote", os.path.relpath(path, REPO))


def crlf(text):
    return text.replace("\r\n", "\n").replace("\n", "\r\n")


def build_data():
    text = read(DATA)
    defs = []
    for name, animset, clip, actors in LEGACY:
        clips = [f"p{i}_{clip}" for i in range(1, actors + 1)]
        defs.append(cutscene(name, animset, clips, f"p1_{clip}", LEGACY_CAMERAS, LEGACY_SYNC_FRAME,
                             LEGACY_CAMERA_MOTION))
    for _, clip, cameras in STORM:
        defs.append(cutscene(storm_cutscene_name(clip), "cutsceneStormPromo", [clip], clip, cameras, 0,
                             STORM_CAMERA_MOTION))
    body = ",\n".join(defs)
    stripped = text.rstrip()
    assert stripped.endswith("}") and LEGACY[0][0] + " =" not in text
    return stripped[:-1].rstrip() + crlf(",\n" + body + "\n}\n")


def group_entries(weight, names):
    return "".join(f'\t\t{{\r\n\t\t\tweight = {weight},\r\n\t\t\tname = "{n}"\r\n\t\t}},\r\n' for n in names)


def add_to_group(text, group, entries):
    head = f"\t{group} = {{\r\n"
    at = text.index(head) + len(head)
    return text[:at] + entries + text[at:]


def build_groups():
    text = read(GROUPS)
    for group in LEGACY_GROUPS:
        text = add_to_group(text, group, group_entries(LEGACY_WEIGHT, [n for n, _, _, _ in LEGACY]))
    for group in STORM_GROUPS:
        text = add_to_group(text, group, group_entries(STORM_POOL_WEIGHT, [storm_cutscene_name(c) for _, c, _ in STORM]))
    return text


def build_rulestate():
    text = read(RULESTATE)
    table = "".join(f'\t{name_key(n)} = "{storm_cutscene_name(c)}",\n' for n, c, _ in STORM)
    helper = f'''local var_0_0 = 10
local var_0_signatureChancePercent = {STORM_CHANCE_PERCENT}
local var_0_signatureCelebrations = {{
{table}}}

-- Storm players' own celebration (cutsceneStormPromo clips), standing tries only.
local function var_0_getSignatureCelebration(arg_0_0, arg_0_1, arg_0_2)
	if arg_0_1 then
		return nil
	end

	local var_0_identity = arg_0_0 and arg_0_0.identity
	local var_0_fullName = var_0_identity and var_0_identity.fullName

	if type(var_0_fullName) ~= "string" then
		return nil
	end

	local var_0_key = string.gsub(string.lower(var_0_fullName), "[^a-z]", "")
	local var_0_cutscene = var_0_signatureCelebrations[var_0_key]

	if var_0_cutscene and var_0_signatureChancePercent < 100 and native.Random.FromTimeValue(arg_0_2):randomIntegerRange(1, 100) > var_0_signatureChancePercent then
		return nil
	end

	return var_0_cutscene
end
'''
    old_head = "local var_0_0 = 10\n"
    old_pick = '''	local var_2_24 = var_2_13.matchType.usingBonusTry or false
'''
    new_pick = '''	var_2_21 = var_0_getSignatureCelebration(var_2_3, arg_2_0.playerIsOnGround, arg_2_8) or var_2_21

	local var_2_24 = var_2_13.matchType.usingBonusTry or false
'''
    lf = text.replace("\r\n", "\n")
    assert lf.count(old_head) == 1 and lf.count(old_pick) == 1
    lf = lf.replace(old_head, helper, 1).replace(old_pick, new_pick, 1)
    return crlf(lf) if "\r\n" in text else lf


def build_camera():
    text = read(CAMERA)
    anchor = '''			if var_5_26 then
				arg_5_7.fov = arg_5_7.fov * var_5_26
			end
		end
'''
    motion = '''
		if arg_5_0.motionPushInFovScale or arg_5_0.motionDollyDistance or arg_5_0.motionSway then
			local var_5_motionT = math.min(1, math.max(0, arg_5_6 / math.max(var_5_6:getDuration(), 0.001)))
			local var_5_motionEase = var_5_motionT * var_5_motionT * (3 - 2 * var_5_motionT)

			if arg_5_0.motionPushInFovScale then
				arg_5_7.fov = arg_5_7.fov * native.lerp1(var_5_motionEase, 1, arg_5_0.motionPushInFovScale)
			end

			if arg_5_0.motionDollyDistance then
				arg_5_7.pos = arg_5_7.pos + arg_5_7.dir * (arg_5_0.motionDollyDistance * var_5_motionEase)
			end

			if arg_5_0.motionSway then
				local var_5_motionRight = native.cross3(arg_5_7.up, arg_5_7.dir)

				arg_5_7.pos = arg_5_7.pos + var_5_motionRight * (math.sin(arg_5_6 * 0.9) * arg_5_0.motionSway) + arg_5_7.up * (math.sin(arg_5_6 * 1.3 + 1) * arg_5_0.motionSway * 0.6)
			end
		end
'''
    lf = text.replace("\r\n", "\n")
    assert lf.count(anchor) == 1
    lf = lf.replace(anchor, anchor + motion, 1)
    return crlf(lf) if "\r\n" in text else lf


if __name__ == "__main__":
    write(DATA, build_data())
    write(GROUPS, build_groups())
    write(RULESTATE, build_rulestate())
    write(CAMERA, build_camera())
