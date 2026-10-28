"""
coach_look.py - turn a readable coach look (coach_looks.json) into the
character creator's visual options, patched into a CCharacterVisualConfig
blob (parse_npcs.visual_set: fixed slots, the blob never changes size).

Item names and guids come from look_item_maps.json, a subset of
design/characters/assetmapitems.lua dumped by look_dump_item_maps.lua (luajit):
    luajit look_dump_item_maps.lua <decompiled>/design/characters/assetmapitems.lua <full.json>
then trimmed to the keys below.

A look (every key optional):
    hair         hair preset guid (ItemMaps.hair, the editor's Style list). The
                 preset's hairTop / hairSide / hairSide2 / hairTexture_cap are
                 resolved to their item guids and set too - the renderer reads
                 those, the preset is only what the editor shows.
    hairColour   [primary, secondary] ItemMaps.hairColours guids (1000-1011
                 are greys, light to dark)
    beard        beard preset guid (ItemMaps.beard), or
    moustache / chinhair / sideburns   item names, for combinations
    beardColour  [primary, secondary] hairColours guids
    stubble      0-3 (head bodyHair_type: player_head_bodyhair_0N)
    stubbleColour  hairColours guid
    skin         skinTexture guid (ColourSwatches.skinColourSwatches)
    eyebrows     0-4 (softangled, angled, curved, rounded, flat)
    crowsFeet    0, 1 or 3 (none, crows_feet_01, crows_feet_02)
    headShape / jawShape / noseShape / eyesShape / mouthShape / ethnicity
                 morph names without the prefix ("oblong", "square", "hook")
    height_cm / weight_kg   converted with a fit over the stock players
                 (visual height slider falls as real height rises)
    redness      0-1 face redness
    age          years: crow's feet, droopier eyelids and jowls (RL26 renders
                 no age option, and the skin textures only vary in undertone)
    build        "lean" / "average" / "heavy" / "muscular": body type, figure
                 and muscle sliders (BUILDS)
    shoes        "dark" (default) colours the boots dark - the shoes slot only
                 has boots and novelty items
    face         {feature: score -1..1} (FACE_FEATURES): moves the creator's
                 advanced face sliders away from a typical face (the median of
                 the stock non-scanned players of that sex, look_face_neutral.json)
                 by score x the players' 5-95% spread. Features left out stay
                 typical; a coach with no "face" gets a seeded random one, so no
                 two coaches share a face.
    raw          {option: value} written as is

Rebuild the bases and neutral faces (stock players from entry 39957, stock
NPCs from 39954):
    python coach_look.py --players <stock>/defaultdata_players --npcs <stock>/defaultdata_npcs
"""

import argparse
import json
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools"))
import parse_npcs as pn  # noqa: E402

MAPS = json.load(open(os.path.join(HERE, "look_item_maps.json"), encoding="utf-8"))
NEUTRAL_PATH = os.path.join(HERE, "look_face_neutral.json")
NEUTRAL = json.load(open(NEUTRAL_PATH, encoding="utf-8")) if os.path.exists(NEUTRAL_PATH) else {}
BASES = {0: os.path.join(HERE, "look_base_male.visual.bin"), 1: os.path.join(HERE, "look_base_female.visual.bin")}

MORPHS = {
    "headShape": ("headShapeMorph_option", "headShapeMorphList", "headShape_"),
    "jawShape": ("jawShapeMorph_option", "jawShapeMorphList", "jawShape_"),
    "noseShape": ("noseShapeMorph_option", "noseShapeMorphList", "noseShape_"),
    "eyesShape": ("eyesShapeMorph_option", "eyesShapeMorphList", "eyesShape_"),
    "mouthShape": ("mouthShapeMorph_option", "mouthShapeMorphList", "mouthShape_"),
    "earsShape": ("earsShapeMorph_option", "earsShapeMorphList", "earsShape_"),
    "ethnicity": ("ethnicityShapeMorph_option", "ethnicityShapeMorphList", "ethnicityShape_"),
}

# Face features -> the advanced sliders they move (editor pads: x = width,
# y = height). A leading "-" moves that slider the other way.
FACE_FEATURES = {
    "faceWidth": ["head_width_option", "skull_width_option", "cheek_width_option", "temple_width_option"],
    "faceLength": ["head_height", "skull_height", "forehead_height"],
    "headSize": ["headSize"],
    "jawWidth": ["jaw_width", "mouth_jowl_width"],
    "jawHeight": ["jaw_height"],
    "jawAngle": ["jaw_angle_height"],
    "chinWidth": ["chin_width"],
    "chinLength": ["chin_height"],
    "chinForward": ["chin_depth_option"],
    "cheekbones": ["cheekbone_width", "cheekbone_height"],
    "brow": ["brow_size", "brow_depth"],
    "browHeight": ["brow_height_option"],
    "noseWidth": ["nose_width_option", "nose_tip_width", "nose_nostril_width"],
    "noseLength": ["nose_height"],
    "noseBridge": ["nose_bridge_width", "nose_break_option"],
    "noseProjection": ["nose_depth_option", "nose_tip_depth"],
    "eyeSize": ["eyes_size"],
    "eyeSpacing": ["eyes_width_option"],
    "eyeHeight": ["eyes_height_option"],
    "eyeDepth": ["eyes_depth"],
    "eyelids": ["eyelid_droop_option"],
    "eyeTilt": ["eye_rotation_option"],
    "mouthWidth": ["mouth_width_option"],
    "lips": ["upper_lip_height_option", "lower_lip_height_option"],
    "earSize": ["ears_size"],
    "earsOut": ["ears_angle_option"],
    "jowls": ["mouth_jowl_width"],
}
# random faces stay inside the stock players' range (x FACE_GAIN at most ~1 spread):
# at 1.0 with the strong jaw some faces looked alien
RANDOM_FACE_SCALE = 0.6
# face scores are multiplied by this before moving the sliders: at 1 the
# first in-game faces (2026-10-27) all still looked alike
FACE_GAIN = 1.6
# shape presets varied per coach (not ethnicity, which changes the whole face)
VARIED_MORPHS = ("headShape", "jawShape", "noseShape", "eyesShape", "mouthShape", "earsShape")
NATURAL_EYES = range(0, 20)  # eye_textures_col 0-19; 20+ are diamond, sapphire ...

# body type (bodyTypeMorphList: 0 ecto, 1 -, 2 endo), physique (0 -, 1
# athletique, 2 heavy), figure (0 -, 1 invTriangle, 4 apple) and muscle sliders
BUILDS = {
    "lean": dict(bodyShapeMorph_option=0, bodyPhysiqueMorph_option=0, bodyFigureMorph_option=0,
                 upperTorso_bodyShape=10, armsUpper_bodyShape=30, armsLower_bodyShape=40, traps_bodyShape=60),
    "average": dict(bodyShapeMorph_option=1, bodyPhysiqueMorph_option=0, bodyFigureMorph_option=0,
                    upperTorso_bodyShape=20, armsUpper_bodyShape=50, armsLower_bodyShape=50, traps_bodyShape=80),
    "heavy": dict(bodyShapeMorph_option=2, bodyPhysiqueMorph_option=2, bodyFigureMorph_option=4,
                  upperTorso_bodyShape=30, armsUpper_bodyShape=60, armsLower_bodyShape=55, traps_bodyShape=90),
    "muscular": dict(bodyShapeMorph_option=1, bodyPhysiqueMorph_option=1, bodyFigureMorph_option=1,
                     upperTorso_bodyShape=90, armsUpper_bodyShape=110, armsLower_bodyShape=70, traps_bodyShape=120),
}
DARK_SHOES = {f"shoeColour{i}_{c}": 25 for i in range(1, 5) for c in "rgb"}


def _clamp(v):
    return max(0, min(255, int(round(v))))


def height_slider(cm):
    return _clamp(-2.983 * (cm - 184.4) + 139.7)


def weight_slider(kg):
    return _clamp(2.054 * (kg - 96.0) + 98.2)


def _item(kind, name):
    if not name:
        return 0
    if name not in MAPS[kind]:
        raise KeyError(f"no {kind} item {name!r}")
    return MAPS[kind][name]


def _preset(kind, guid):
    for it in MAPS[kind]:
        if it["guid"] == guid:
            return it
    raise KeyError(f"no {kind} preset {guid}")


def options(look):
    """Look -> {visual option: value} (everything but the face)."""
    out = {}
    if "hair" in look:
        p = _preset("hair", look["hair"])
        out.update(hair=p["guid"], hairTop=_item("hairTop", p.get("hairTop")),
                   hairSide=_item("hairSide", p.get("hairSide")), hairSide2=_item("hairSide2", p.get("hairSide2")),
                   hairTexture_cap=_item("hairCap_col", p.get("hairTexture_cap")))
    if "hairColour" in look:
        out["hairColour1"], out["hairColour2"] = look["hairColour"]
    if "beard" in look:
        p = _preset("beard", look["beard"])
        out.update(beard=p["guid"], moustache=_item("moustache", p.get("moustache")),
                   chinhair=_item("chinhair", p.get("chinhair")), sideburns=_item("sideburns", p.get("sideburns")))
    for part in ("moustache", "chinhair", "sideburns"):
        if part in look:
            out[part] = _item(part, look[part])
    if "beardColour" in look:
        out["beardColour1"], out["beardColour2"] = look["beardColour"]
    if "stubble" in look:
        out["bodyHair_type"] = look["stubble"]
    if "stubbleColour" in look:
        out["bodyHair_colour"] = look["stubbleColour"]
    for key, opt in (("skin", "skinTexture"), ("eyebrows", "eyebrows_type"), ("crowsFeet", "crowsFeet_option")):
        if key in look:
            out[opt] = look[key]
    for key, (opt, lst, prefix) in MORPHS.items():
        if key in look:
            name = look[key]
            out[opt] = 0 if name in (None, "", "none") else MAPS[lst].get(name, MAPS[lst].get(prefix + name))
            if out[opt] is None:
                raise KeyError(f"no {lst} entry {name!r}")
    if "height_cm" in look:
        out["height"] = height_slider(look["height_cm"])
    if "weight_kg" in look:
        out["weight"] = weight_slider(look["weight_kg"])
    if "redness" in look:
        out["redness_face_amount"] = _clamp(look["redness"] * 255)
    if "age" in look and "crowsFeet" not in look:
        out["crowsFeet_option"] = 3 if look["age"] >= 50 else 1 if look["age"] >= 35 else 0
    out.update(BUILDS[look.get("build", "average")])
    if look.get("shoes", "dark") == "dark":
        out.update(DARK_SHOES)
    out.update(look.get("raw", {}))
    return out


def random_face(seed):
    rng = random.Random(seed)
    return {f: round(rng.uniform(-RANDOM_FACE_SCALE, RANDOM_FACE_SCALE), 2) for f in FACE_FEATURES}


def face_options(face, sex):
    """{feature: score} -> {slider: value}: every face slider at the typical
    value, then each feature's sliders moved by score x spread (at least 60
    either way where the players never move a slider off its usual value)."""
    neutral = NEUTRAL[str(sex)]
    out = {name: n["neutral"] for name, n in neutral.items()}
    for feature, score in face.items():
        if feature not in FACE_FEATURES:
            raise KeyError(f"unknown face feature {feature!r}")
        for name in FACE_FEATURES[feature]:
            sign = -1 if name.startswith("-") else 1
            name = name.lstrip("-")
            if name not in neutral:
                continue
            n = neutral[name]
            v = score * sign * FACE_GAIN
            up = max(n["hi"] - n["neutral"], min(60, 255 - n["neutral"]))
            down = max(n["neutral"] - n["lo"], min(60, n["neutral"]))
            out[name] = _clamp(n["neutral"] + (v * up if v > 0 else v * down))
    return out


# what vary() picks from for coaches whose look leaves it out
MALE_HAIR = [1, 21, 36, 37, 39, 40, 42, 43, 45, 70, 71, 72, 75, 76, 77, 80, 81, 85, 86, 105, 106, 120, 121, 125,
             126, 130, 135, 140, 145, 155, 160, 165, 175, 230, 231, 240, 250, 251, 265, 266, 270, 275, 285, 295,
             305, 330, 336, 389, 391]
FEMALE_HAIR = [360, 420, 424, 510, 511, 512, 600, 601, 602, 610, 611]
DARK_HAIR = [[345, 344], [325, 324], [224, 225], [125, 224], [344, 345], [330, 329]]
FAIR_HAIR = [[0, 1], [100, 101], [300, 301], [124, 125], [500, 501]]
GREY_HAIR = [[1000, 1002], [1002, 1004], [1004, 1006], [1006, 1008], [1008, 1009], [98, 1001]]
# facial hair: (stubble, beard parts)
MALE_FACIAL_HAIR = [
    (0, {}), (1, {}), (1, {}), (2, {}), (2, {}), (3, {}),
    (1, {"chinhair": "chin_goatee01"}),
    (2, {"moustache": "moustache_basic01", "chinhair": "chin_goatee01"}),
    (1, {"moustache": "moustache_basic01"}),
    (3, {"moustache": "moustache_basic01", "chinhair": "chin_middleMedium01"}),
]
SKIN_TONE_WEIGHTS = [3, 4, 4, 3, 2, 1, 1, 0.5]  # skinTexture tone 0 (lightest) .. 7


def vary(look, seed, sex=0):
    """Fill what the look leaves out with seeded picks, so no two coaches
    look alike: hair style and colour (greyer with age), facial hair, skin
    tone (or just the undertone when the look sets one: skinTexture guids
    0-31 are 8 tones x variants a/c/b/d), age, build, a shape preset for
    head, jaw, nose, eyes, mouth and ears, eye colour and eyebrows."""
    rng = random.Random(seed * 7919 + 17)
    look = dict(look)
    female = sex == 1
    look.setdefault("age", rng.randint(35, 55) if female else rng.randint(38, 68))
    look.setdefault("build", rng.choice(["lean", "average", "average", "average", "heavy"]))
    if "hair" not in look:
        look["hair"] = rng.choice(FEMALE_HAIR if female else MALE_HAIR)
    if "hairColour" not in look:
        grey_chance = 0 if female else max(0.0, min(0.9, (look["age"] - 40) / 25))
        pool = GREY_HAIR if rng.random() < grey_chance else rng.choice([DARK_HAIR, DARK_HAIR, FAIR_HAIR])
        look["hairColour"] = list(rng.choice(pool))
    if not female and not any(k in look for k in ("beard", "moustache", "chinhair", "sideburns", "stubble")):
        stubble, parts = rng.choice(MALE_FACIAL_HAIR)
        look.update(beard=0, stubble=stubble, **parts)
        look.setdefault("beardColour", look["hairColour"])
    look.setdefault("stubbleColour", look["hairColour"][0])
    if "skin" in look:
        if look["skin"] < 32:
            look["skin"] = rng.randrange(4) * 8 + look["skin"] % 8
    else:
        tone = rng.choices(range(8), SKIN_TONE_WEIGHTS)[0]
        look["skin"] = rng.randrange(4) * 8 + tone
    for key in VARIED_MORPHS:
        if key not in look:
            opt, lst, prefix = MORPHS[key]
            look[key] = rng.choice(["none"] + list(MAPS[lst]))
    raw = dict(look.get("raw", {}))
    raw.setdefault("eyeTexture", rng.choice(NATURAL_EYES))
    look["raw"] = raw
    look.setdefault("eyebrows", rng.randrange(5))
    return look


def apply(blob, look, sex, seed):
    """Patch a visual blob (bytes) with a look: the face (the look's, or a
    random one from seed), seeded variety for whatever the look leaves out,
    then everything else. Options the blob's layout lacks are reported, not
    fatal."""
    blob = bytearray(blob)
    skipped = []
    random_jaw = "face" not in look
    look = vary(look, seed, sex)
    face = dict(look["face"] if "face" in look else random_face(seed))
    if random_jaw:
        # a clearly different (but still natural) jawline and chin for every random face
        rng = random.Random(seed * 104729 + 3)
        for feature in ("jawWidth", "jawHeight", "jawAngle", "chinWidth", "chinLength", "faceWidth"):
            face[feature] = rng.choice([-0.6, -0.4, 0.4, 0.6])
    if "age" in look:
        older = max(0.0, min(1.0, (look["age"] - 35) / 30))
        for feature in ("eyelids", "jowls"):
            face[feature] = max(-1.0, min(1.0, face.get(feature, 0) + older))
    opts = face_options(face, sex) if str(sex) in NEUTRAL else {}
    opts.update(options(look))
    for name, value in opts.items():
        try:
            pn.visual_set(blob, name, value)
        except KeyError:
            skipped.append(name)
    return bytes(blob), skipped


def make_base(player_blob, generic_blob):
    """A neutral, editable base: a non-scanned player's full option layout
    (it has the hair / beard preset slots the generic NPC looks lack), with
    the generic NPC's values copied over wherever the two layouts share an
    option of the same width, and no player gear or tattoos."""
    blob = bytearray(player_blob)
    ds, lay = pn.visual_layout(blob)
    gs, glay = pn.visual_layout(generic_blob)
    for h, (off, width) in lay.items():
        if h in glay and glay[h][1] == width:
            goff = glay[h][0]
            blob[ds + off:ds + off + width] = generic_blob[gs + goff:gs + goff + width]
    tattoos = tuple(f"{p}Tattoo_type" for p in ("leftArm", "rightArm", "leftLeg", "rightLeg", "leftNeck",
                                                 "rightNeck", "midNeck"))
    for name in ("hat", "mouthguard", "helmet", "headwear", "compression_option") + tattoos + tuple(
            f"strapping_{p}_option" for p in (
                "shoulderLeft", "shoulderRight", "elbowLeft", "elbowRight", "wristLeft", "wristRight",
                "handLeft", "handRight", "kneeLeft", "kneeRight", "thighLeft", "thighRight",
                "armbandLeft", "armbandRight", "fingerpointerLeft", "fingerpointerRight",
                "fingermiddleLeft", "fingermiddleRight", "fingerringLeft", "fingerringRight",
                "fingerpinkyLeft", "fingerpinkyRight")):
        try:
            pn.visual_set(blob, name, 0)
        except KeyError:
            pass
    return bytes(blob)


def _value(blob, name):
    try:
        return pn.visual_get(blob, name)[0]
    except KeyError:
        return None


def build_assets(players_path, npcs_path):
    """Write look_base_{male,female}.visual.bin and look_face_neutral.json."""
    import bigant_db
    players = bigant_db.load(open(players_path, "rb").read()).records
    npcs = bigant_db.load(open(npcs_path, "rb").read()).by_id()
    generic = {0: npcs[455]["visual"], 1: npcs[456]["visual"]}
    neutral = {}
    for sex in (0, 1):
        pool = [r for r in players if _value(r["visual"], "head") == 0 and _value(r["visual"], "sex") == sex
                and _value(r["visual"], "hair") is not None]
        # base on the most common layout among them
        by_size = {}
        for r in pool:
            by_size.setdefault(len(pn.visual_layout(r["visual"])[1]), []).append(r)
        template = max(by_size.values(), key=len)[0]
        base = make_base(template["visual"], generic[sex])
        with open(BASES[sex], "wb") as f:
            f.write(base)
        ds, lay = pn.visual_layout(base)
        table = {}
        for name in sorted({n.lstrip("-") for names in FACE_FEATURES.values() for n in names}):
            if pn.fnv1a32(name) not in lay:
                continue
            vals = sorted(v for v in (_value(r["visual"], name) for r in pool) if v is not None and v <= 255)
            table[name] = {"neutral": vals[len(vals) // 2], "lo": vals[len(vals) // 20],
                           "hi": vals[19 * len(vals) // 20]}
        neutral[str(sex)] = table
        print(f"sex {sex}: base from player {template['tables'][0]['id']} ({len(lay)} options, "
              f"{len(pool)} non-scanned players), {len(table)} face sliders")
    with open(NEUTRAL_PATH, "w", encoding="utf-8") as f:
        json.dump(neutral, f, indent=0)


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--players", required=True, help="stock defaultdata_players (entry 39957)")
    ap.add_argument("--npcs", required=True, help="stock defaultdata_npcs (entry 39954)")
    args = ap.parse_args()
    build_assets(args.players, args.npcs)
