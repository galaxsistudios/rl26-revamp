"""
nrl_site_logos.py - download every team logo (SVG) that nrl.com's draw data
lists, grouped <out>/<comp folder>/<theme key>/<file>.svg, plus each
competition's own badge under _competition/.

The draw data (https://www.nrl.com/draw/data?competition=N&season=Y) lists
each team's theme key and logo files; they're served from
https://www.nrl.com/.theme/<key>/<file>. Seasons are merged per comp, so
teams that only appeared in an older season (e.g. the 2017 / 2022 World
Cups) are picked up too. The players data
(https://www.nrl.com/players/data/?competition=N) is merged in as well: it
lists teams the draw doesn't have yet (e.g. the Perth Bears before their
first season). Only .svg files are kept, and each is given a
width of at least 1500px (viewBox untouched, height kept in proportion).

index.json records names / theme key / files per comp and team; a run
updates only the comps it downloads.

Usage:
    python tools/nrl_site_logos.py resources/nrl-site-logos [folder ...]
"""

import json
import os
import re
import sys
import time
import urllib.request

# folder -> (competition id, seasons; None = the current season)
COMPS = {
    "nrl": (111, [None]),
    "state-of-origin": (116, [None]),
    "nswrl": (113, [None]),
    "qrl": (114, [None]),
    "world-cup": (131, [2026, 2022, 2017]),
    "womens-world-cup": (157, [2026, 2022, 2017]),
    "internationals": (133, [2026, 2022, 2017]),
    "womens-internationals": (135, [2026, 2022]),
}
MIN_WIDTH = 1500
UA = {"User-Agent": "Mozilla/5.0"}


def get(url):
    for _ in range(3):
        try:
            return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30).read()
        except Exception as e:
            err = e
            time.sleep(1)
    raise err


def merge(teams, name, theme):
    t = teams.setdefault(theme["key"], {"names": set(), "logos": {}})
    t["names"].add(name)
    for f, v in theme.get("logos", {}).items():
        t["logos"][f] = max(v, t["logos"].get(f, v))


def fmt(x):
    return ("%.3f" % x).rstrip("0").rstrip(".")


def widen(svg):
    """Set the root <svg> width to at least MIN_WIDTH, height from the viewBox."""
    m = re.search(r"<svg\b[^>]*>", svg)
    tag = m.group(0)
    vb = [float(v) for v in re.search(r'viewBox="([^"]*)"', tag).group(1).replace(",", " ").split()]
    w = re.search(r'\swidth="([\d.]+)(px)?"', tag)
    width = max(MIN_WIDTH, float(w.group(1)) if w else 0)
    new = re.sub(r'\s(width|height)="[^"]*"', "", tag)
    new = new.replace("<svg", f'<svg width="{fmt(width)}" height="{fmt(width * vb[3] / vb[2])}"', 1)
    return svg[:m.start()] + new + svg[m.end():]


def main():
    out = sys.argv[1]
    folders = sys.argv[2:] or list(COMPS)
    index_path = os.path.join(out, "index.json")
    summary = json.load(open(index_path)) if os.path.exists(index_path) else {}
    for folder in folders:
        cid, seasons = COMPS[folder]
        teams = {}
        comp = None
        urls = [f"https://www.nrl.com/draw/data?competition={cid}" + (f"&season={season}" if season else "")
                for season in seasons]
        urls.append(f"https://www.nrl.com/players/data/?competition={cid}")
        for url in urls:
            d = json.loads(get(url))
            for t in d.get("filterTeams", []):
                merge(teams, t["name"], t["theme"])
            for fx in d.get("fixtures", []):
                for side in ("homeTeam", "awayTeam"):
                    if side in fx and "theme" in fx[side]:
                        merge(teams, fx[side]["nickName"], fx[side]["theme"])
            comp = comp or next(c for c in d["filterCompetitions"] if c["value"] == cid)
        targets = [("_competition", {"names": {comp["name"]}, "logos": comp["theme"]["logos"]}, comp["theme"]["key"])]
        targets += [(k, v, k) for k, v in sorted(teams.items())]
        summary[folder] = {}
        for dirname, info, key in targets:
            files = []
            for f, bust in sorted(info["logos"].items()):
                if not f.endswith(".svg"):
                    continue
                svg = get(f"https://www.nrl.com/.theme/{key}/{f}?bust={bust}").decode("utf-8")
                dst = os.path.join(out, folder, dirname)
                os.makedirs(dst, exist_ok=True)
                with open(os.path.join(dst, f), "w", encoding="utf-8", newline="") as fh:
                    fh.write(widen(svg))
                files.append(f)
            if files:
                summary[folder][dirname] = {"names": sorted(info["names"]), "themeKey": key, "files": files}
            print(folder, dirname, len(files))
    with open(index_path, "w") as f:
        json.dump(summary, f, indent=2)


if __name__ == "__main__":
    main()
