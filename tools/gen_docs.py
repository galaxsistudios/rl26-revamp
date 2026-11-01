#!/usr/bin/env python3
"""
gen_docs.py - regenerate docs/our-changes/: what every mod changes compared
with Big Ant's shipped game, read from the repo itself so it can't drift.

For each mods/<mod>/ it lists:
  - Lua overrides (src/script-game/...) with a line diff against the stock
    decompiled file (decompiled/src/...), so "how much of Big Ant's file did we
    touch" is visible at a glance;
  - Noesis XAML / font overrides (noesis/workspace/...);
  - database record overrides (defaultdata/<db>/*.json: patched vs new records);
  - career data files (career/*), texture replacements (textures/*.dds);
  - its own programs (*.py: installers, generators, exe patchers);
  - the first paragraph of its README.

Writes docs/our-changes/README.md (summary table), docs/our-changes/mods/<mod>.md
(one page per mod) and docs/our-changes/stock-files.md (stock file -> the mods
that override it).

    python tools\\gen_docs.py
"""

import difflib
import glob
import os
import re
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODS = os.path.join(ROOT, "mods")
STOCK_LUA = os.path.join(ROOT, "decompiled")
STOCK_XAML = os.path.join(ROOT, "extracted")
OUT = os.path.join(ROOT, "docs", "our-changes")


def read(path):
    with open(path, encoding="utf-8-sig", errors="replace") as f:
        return f.read()


def readme_summary(mod):
    path = os.path.join(MODS, mod, "README.md")
    if not os.path.exists(path):
        return ""
    text = read(path)
    paras = [p.strip() for p in re.split(r"\n\s*\n", text) if p.strip() and not p.lstrip().startswith("#")]
    return re.sub(r"\s+", " ", paras[0]) if paras else ""


def diff_stat(stock, mine):
    a, b = read(stock).splitlines(), read(mine).splitlines()
    added = removed = 0
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, a, b, autojunk=False).get_opcodes():
        if tag in ("replace", "delete"):
            removed += i2 - i1
        if tag in ("replace", "insert"):
            added += j2 - j1
    return len(a), added, removed


def scan(mod):
    base = os.path.join(MODS, mod)
    info = {"lua": [], "xaml": [], "data": defaultdict(lambda: [0, 0]), "career": [], "textures": [], "py": [],
            "other": []}
    for dirpath, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d not in ("__pycache__", ".git")]
        for name in files:
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, base).replace("\\", "/")
            if rel.startswith("src/") and name.endswith(".lua"):
                stock = os.path.join(STOCK_LUA, *rel.split("/"))
                info["lua"].append((rel[4:], diff_stat(stock, path) if os.path.exists(stock) else None))
            elif rel.startswith("noesis/"):
                stock = os.path.join(STOCK_XAML, *rel.split("/"))
                stat = diff_stat(stock, path) if os.path.exists(stock) and name.endswith(".xaml") else None
                info["xaml"].append((rel, stat))
            elif rel.startswith("defaultdata/") and name.endswith(".json"):
                db = rel.split("/")[1]
                try:
                    import json
                    new = json.load(open(path)).get("new", False)
                except Exception:
                    new = False
                info["data"][db][1 if new else 0] += 1
            elif rel.startswith("career/"):
                info["career"].append(rel)
            elif rel.startswith("textures/"):
                info["textures"].append(rel)
            elif name.endswith(".py") and "/" not in rel:
                info["py"].append(rel)
    for key in ("lua", "xaml", "career", "textures", "py"):
        info[key].sort()
    return info


def kinds(info):
    out = []
    if info["lua"]:
        out.append(f"{len(info['lua'])} Lua")
    if info["xaml"]:
        out.append(f"{len(info['xaml'])} UI")
    for db, (patched, new) in sorted(info["data"].items()):
        out.append(f"{db.replace('defaultdata_', '')} {patched}" + (f"+{new} new" if new else ""))
    if info["career"]:
        out.append(f"{len(info['career'])} career")
    if info["textures"]:
        out.append(f"{len(info['textures'])} textures")
    if any(p in ("install.py",) for p in info["py"]):
        out.append("installer")
    return ", ".join(out) or "-"


def mod_page(mod, info):
    lines = [f"# {mod}", "", f"Source: [mods/{mod}](../../../mods/{mod}/)"
             + (f" - [README](../../../mods/{mod}/README.md)" if os.path.exists(os.path.join(MODS, mod, "README.md")) else ""),
             "", readme_summary(mod) or "_(no README)_", ""]
    if info["lua"]:
        lines += ["## Lua overrides (whole-file, scripts bundle)", "",
                  "Diff against Big Ant's decompiled file: lines added / removed of the stock total.", "",
                  "| Stock file | Stock lines | + | - |", "|---|---:|---:|---:|"]
        for rel, stat in info["lua"]:
            link = f"[{rel}](../../../mods/{mod}/src/{rel})"
            lines.append(f"| {link} | " + (" | ".join(str(x) for x in stat) if stat else "new / not in stock | | ") + " |")
        lines.append("")
    if info["xaml"]:
        lines += ["## Noesis UI overrides (xamls / fonts bundles)", "", "| File | Stock lines | + | - |", "|---|---:|---:|---:|"]
        for rel, stat in info["xaml"]:
            lines.append(f"| {rel} | " + (" | ".join(str(x) for x in stat) if stat else "binary or new | | ") + " |")
        lines.append("")
    if info["data"]:
        lines += ["## Database records", "", "| Database | Patched records | New records |", "|---|---:|---:|"]
        for db, (patched, new) in sorted(info["data"].items()):
            lines.append(f"| {db} | {patched} | {new} |")
        lines.append("")
    if info["career"]:
        lines += ["## Career data (careerdata bundle, whole files)", ""] + [f"- `{r}`" for r in info["career"]] + [""]
    if info["textures"]:
        lines += [f"## Texture replacements: {len(info['textures'])}", ""]
        lines += [f"- `{r}`" for r in info["textures"][:30]]
        if len(info["textures"]) > 30:
            lines.append(f"- ... and {len(info['textures']) - 30} more")
        lines.append("")
    if info["py"]:
        lines += ["## Programs", "", "Generators, installers and exe patchers the mod runs itself (see its README):", ""]
        lines += [f"- [{p}](../../../mods/{mod}/{p})" for p in info["py"]] + [""]
    return "\n".join(lines)


def main():
    mods = sorted(d for d in os.listdir(MODS) if os.path.isdir(os.path.join(MODS, d)) and not d.startswith((".", "_")))
    infos = {m: scan(m) for m in mods}
    os.makedirs(os.path.join(OUT, "mods"), exist_ok=True)
    for m, info in infos.items():
        with open(os.path.join(OUT, "mods", f"{m}.md"), "w", encoding="utf-8", newline="\n") as f:
            f.write(mod_page(m, info) + "\n")

    # summary
    total_lua = sum(len(i["lua"]) for i in infos.values())
    lines = ["# Our changes vs Big Ant's game", "",
             "_Generated by `python tools/gen_docs.py` from `mods/`. Don't edit by hand: rerun it._", "",
             f"{len(mods)} mods. Every change ships as a mod folder; nothing edits the game in place except through",
             "the tools in `tools/` (see [INSTRUCTIONS.md](../../INSTRUCTIONS.md)). How Big Ant's own game is put",
             "together is in [../big-ant-base/](../big-ant-base/README.md).", "",
             f"- {total_lua} whole-file Lua overrides of Big Ant scripts ([stock-files.md](stock-files.md) lists",
             "  which stock file each mod replaces, and which files more than one mod depends on).",
             "- Database edits are per-record JSON patches applied to the stock databases at build time",
             "  (`tools/data_mods.py`), never edited copies of the databases.",
             "- Art is appended to the archive as new entries or replaces stock entries one by one, with a",
             "  backup per entry (`tools/pack.py`, `tools/add_entries.py`).", "",
             "| Mod | What it changes | Summary |", "|---|---|---|"]
    for m in mods:
        summary = readme_summary(m)
        if len(summary) > 220:
            summary = summary[:217].rsplit(" ", 1)[0] + "..."
        lines.append(f"| [{m}](mods/{m}.md) | {kinds(infos[m])} | {summary.replace('|', '/')} |")
    with open(os.path.join(OUT, "README.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")

    # stock file -> mods
    owners = defaultdict(list)
    for m, info in infos.items():
        for rel, stat in info["lua"]:
            owners[rel].append((m, stat))
        for rel, stat in info["xaml"]:
            owners[rel].append((m, stat))
    lines = ["# Big Ant files we override", "",
             "_Generated by `python tools/gen_docs.py`._", "",
             "Each row is one of Big Ant's shipped files that a mod replaces whole. `tools/build.py` refuses two",
             "mods owning the same file, so each has exactly one owner. Mods that need to change another mod's",
             "file hook it at runtime instead (see big-ant-base/lua-scripting.md, 'hooking').", "",
             "| Stock file | Mod | Stock lines | + | - |", "|---|---|---:|---:|---:|"]
    for rel in sorted(owners):
        for m, stat in owners[rel]:
            lines.append(f"| `{rel}` | [{m}](mods/{m}.md) | " + (" | ".join(str(x) for x in stat) if stat else "- | | ") + " |")
    with open(os.path.join(OUT, "stock-files.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    print(f"{len(mods)} mods, {len(owners)} stock files -> {os.path.relpath(OUT, ROOT)}")


if __name__ == "__main__":
    main()
