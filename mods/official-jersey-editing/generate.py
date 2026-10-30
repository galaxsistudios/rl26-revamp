"""official-jersey-editing data generator.

Reads the stock uniformTop items (decompiled assetmapitems.lua) and rewrites the
UniformTopTemplates block in jesse-southwell-hair's assetmap.lua (that mod owns the
file; the resolver that applies a template lives next to the block).

A template is a "manufacturer cut": the jersey mesh (item name, e.g. top_round05) plus
its generic seam normal/material maps (m_top_setin_*, m_top_raglan_*, m_top_roundNN,
top_custom_*). Maps named after one kit (m_top_seaEagles_nrl_home_25_nrm, ...) carry
that kit's embossed pattern, so they're left out. Each template is one stock item
(the lowest guid with that mesh + maps); an official kit stores the template's index
in this list, so the list is append-only: existing rows keep their position and new
ones go on the end.

Run from the repo root: python mods/official-jersey-editing/generate.py
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ITEMS = os.path.join(ROOT, "decompiled", "src", "script-game", "design", "characters", "assetmapitems.lua")
ASSETMAP = os.path.join(ROOT, "mods", "jesse-southwell-hair", "src", "script-game", "design", "characters", "assetmap.lua")

JERSEY_MESH = re.compile(r"^top_(round|vneck|soft|flat)\d+$")
GENERIC_MAP = re.compile(r"^(m_top_(setin|raglan)_[a-z]+(_\d+)?|m_top_round\d+|top_custom_\w+)_(nrm|mat)$")
BLOCK = re.compile(r"(-- BEGIN UniformTopTemplates[^\n]*\n).*?(\n-- END UniformTopTemplates)", re.S)


def top_items():
    """uniformTop item_setup rows as {field: raw Lua value string}."""
    lines = open(ITEMS, encoding="utf-8-sig").read().split("\n")
    start = next(i for i, ln in enumerate(lines) if ln == "\tuniformTop = {")
    end = next(i for i in range(start + 1, len(lines)) if re.match(r"^\t\w+ = \{$", lines[i]))
    items, cur = [], None
    for ln in lines[start:end]:
        if re.match(r"^\t\t\t\{$", ln):
            cur = {}
        elif re.match(r"^\t\t\t\},?$", ln) and cur is not None:
            items.append(cur)
            cur = None
        elif cur is not None:
            m = re.match(r"^\t\t\t\t(\w+) = (.*?),?$", ln)
            if m:
                cur[m.group(1)] = m.group(2).strip('"')
    return [i for i in items if "guid" in i and i["guid"].isdigit()]


def label(item):
    maps = re.sub(r"^m_top_|_nrm$", "", item["nrmTexture"]).replace("_", " ")
    return f"{item['sex']} {item['name']} / {maps}"


def main():
    candidates = {}
    for item in sorted(top_items(), key=lambda i: int(i["guid"])):
        if "colTexture" not in item or not JERSEY_MESH.match(item.get("name", "")):
            continue
        if not all(GENERIC_MAP.match(item.get(k, "")) for k in ("nrmTexture", "matTexture")):
            continue
        key = (item["sex"], item["name"], item["nrmTexture"], item["matTexture"])
        candidates.setdefault(key, item)

    src = open(ASSETMAP, encoding="utf-8-sig").read()
    block = BLOCK.search(src)
    if not block:
        sys.exit(f"{ASSETMAP}: UniformTopTemplates markers not found")
    kept = [int(g) for g in re.findall(r"\{ guid = (\d+) \}", block.group(0))]
    by_guid = {int(i["guid"]): i for i in candidates.values()}
    gone = [g for g in kept if g not in by_guid]
    if gone:
        # a stock item went away: keep its row (the resolver skips a missing guid)
        print(f"warning: template guids no longer generic stock items: {gone}")
    new = sorted((g for g in by_guid if g not in kept), key=lambda g: (by_guid[g]["sex"], g))
    rows = kept + new

    body = "UniformTopTemplates = {\n" + ",\n".join(
        f"\t{{ guid = {g} }}" + (f" -- {i + 1}: {label(by_guid[g])}" if g in by_guid else f" -- {i + 1}: (missing)")
        for i, g in enumerate(rows)) + "\n}"
    # the comment sits after the comma Lua needs, so move the commas in front of it
    body = re.sub(r"\} -- ([^\n]*),\n", r"}, -- \1\n", body)
    src = BLOCK.sub(lambda m: m.group(1) + body + m.group(2), src)
    with open(ASSETMAP, "w", encoding="utf-8-sig", newline="") as fh:
        fh.write(src)

    per_sex = {s: sum(1 for g in rows if g in by_guid and by_guid[g]["sex"] == s) for s in ("m", "f")}
    print(f"UniformTopTemplates: {len(rows)} rows ({len(new)} new), male {per_sex['m']}, female {per_sex['f']}")


if __name__ == "__main__":
    main()
