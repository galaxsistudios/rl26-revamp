"""unlock-tier1-editing data generator.

Reads the stock player database (the entry 39957 backup) and the tier-1 head list
(decompiled assetmapitems.lua), then:

1. writes defaultdata/defaultdata_players/<id>_<Surname>.json = {"visual": {"helmet": 0}}
   for every scanned player whose head has no fitted headwear mesh but whose stored
   helmet option is not 0. Stock never drew that headgear (the scan has no mesh for
   it). Once the headWear slot honours the option, the generic mesh would appear in
   matches, so the data is set to what the game showed.
2. rewrites the FittedHeadwearKinds block in jesse-southwell-hair's assetmap.lua:
   scan head -> kind ("gear", "strap", "ribbon") of its head + 1000 mesh, taken from
   the helmet option of the stock player with that head.

Run from the repo root: python mods/unlock-tier1-editing/generate.py
"""
import collections
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import extract_m3mp  # noqa: E402
import parse_npcs as pn  # noqa: E402
import parse_players as pp  # noqa: E402

MOD = os.path.join(ROOT, "mods", "unlock-tier1-editing")
OUT_DIR = os.path.join(MOD, "defaultdata", "defaultdata_players")
STOCK_BLOB = os.path.join(ROOT, "_backup", "entry_39957.blob.bak")
ITEMS = os.path.join(ROOT, "decompiled", "src", "script-game", "design", "characters", "assetmapitems.lua")
ASSETMAP = os.path.join(ROOT, "mods", "jesse-southwell-hair", "src", "script-game", "design", "characters", "assetmap.lua")

GEAR = {1, 2, 100, 101, 120, 130}
STRAP = set(range(20, 25))
RIBBON = {200, 201, 202, 210, 211, 212}


def kind_of(helmet):
    if helmet in GEAR:
        return "gear"
    if helmet in STRAP:
        return "strap"
    if helmet in RIBBON:
        return "ribbon"
    return None


def tier1_heads():
    """{head guid: has a fitted headwear mesh} from ItemMaps.tier1head."""
    src = open(ITEMS, encoding="utf-8-sig").read()
    start = src.index("\n\ttier1head = {")
    end = re.compile(r"\n\t[a-zA-Z0-9_]+ = \{").search(src, start + 1).start()
    heads = {}
    for block in re.findall(r"\n\t\t\t\{(.*?)\n\t\t\t\}", src[start:end], re.S):
        guid = re.search(r"\bguid = (\d+)", block)
        if guid:
            heads[int(guid.group(1))] = "headwear = true" in block
    return heads


def generic_hair_heads():
    src = open(ASSETMAP, encoding="utf-8-sig").read()
    block = re.search(r"GenericHairHeads = \{(.*?)\}", src, re.S).group(1)
    return {int(x) for x in re.findall(r"\[(\d+)\]", block)}


def helmet_set_elsewhere():
    """Player ids whose helmet another mod already sets."""
    ids = set()
    for path in glob.glob(os.path.join(ROOT, "mods", "*", "defaultdata", "defaultdata_players", "*.json")):
        if os.path.normcase(os.path.dirname(path)) == os.path.normcase(OUT_DIR):
            continue
        data = json.load(open(path, encoding="utf-8"))
        if "helmet" in data.get("visual", {}):
            ids.add(int(re.match(r"\d+", os.path.basename(path)).group(0)))
    return ids


def main():
    heads = tier1_heads()
    generic = generic_hair_heads()
    skip_ids = helmet_set_elsewhere()
    names, files = extract_m3mp.decode_m3mp(open(STOCK_BLOB, "rb").read())
    data = files["defaultdata/defaultdata_players"]
    anchors = pp.find_anchors(data)

    kinds = collections.defaultdict(set)
    normalise = []
    for i, anchor in enumerate(anchors):
        vstart, vend = pn.record_visual_span(data, anchors, i)
        blob = data[vstart:vend]
        head = pn.visual_get(blob, "head")[0]
        helmet = pn.visual_get(blob, "helmet")[0]
        if head not in heads or head in generic:
            continue
        if heads[head]:
            if kind_of(helmet):
                kinds[head].add(kind_of(helmet))
        elif helmet != 0 and anchor[2] not in skip_ids:
            normalise.append((anchor[2], anchor[4], helmet))

    clashes = {h: k for h, k in kinds.items() if len(k) > 1}
    if clashes:
        sys.exit(f"heads worn with more than one kind of item: {clashes}")
    fitted = {h: next(iter(k)) for h, k in sorted(kinds.items())}
    unknown = sorted(h for h, has in heads.items() if has and h not in fitted and h not in generic)

    for old in glob.glob(os.path.join(OUT_DIR, "*.json")):
        os.remove(old)
    if normalise:
        os.makedirs(OUT_DIR, exist_ok=True)
    elif os.path.isdir(OUT_DIR):
        os.removedirs(OUT_DIR)
    for pid, surname, helmet in normalise:
        safe = re.sub(r"[^A-Za-z0-9]", "", surname if isinstance(surname, str) else surname.decode("latin-1"))
        path = os.path.join(OUT_DIR, f"{pid:06d}_{safe}.json")
        with open(path, "w", encoding="utf-8", newline="\n") as fh:
            json.dump({"visual": {"helmet": 0}}, fh, indent=2)
            fh.write("\n")

    entries = [f"[{h}] = \"{k}\"" for h, k in fitted.items()]
    rows = [", ".join(entries[i:i + 8]) for i in range(0, len(entries), 8)]
    table = "FittedHeadwearKinds = {\n" + ",\n".join("\t" + r for r in rows) + "\n}"
    src = open(ASSETMAP, encoding="utf-8-sig").read()
    pattern = re.compile(r"(-- BEGIN FittedHeadwearKinds[^\n]*\n).*?(\n-- END FittedHeadwearKinds)", re.S)
    if not pattern.search(src):
        sys.exit(f"{ASSETMAP}: FittedHeadwearKinds markers not found")
    src = pattern.sub(lambda m: m.group(1) + table + m.group(2), src)
    with open(ASSETMAP, "w", encoding="utf-8-sig", newline="") as fh:
        fh.write(src)

    print(f"tier-1 heads: {len(heads)}, with a fitted headwear mesh: {sum(heads.values())}")
    print(f"FittedHeadwearKinds: {len(fitted)} heads ({collections.Counter(fitted.values())})")
    print(f"fitted heads with no stock wearer kind (generic mesh only): {unknown}")
    print(f"helmet -> 0 for {len(normalise)} scanned players without a fitted mesh: "
          f"{collections.Counter(h for _, _, h in normalise)}")


if __name__ == "__main__":
    main()
