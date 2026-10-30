"""
gol_logos.py - download the current club logos from Gallery of League's
British rugby league index (https://galleryofleague.com/british-rugby-league-history/),
which shows one ~1000px transparent PNG per club, in page order:
Super League, Championship, other clubs, internationals.

Writes <out>/<section>/<club>/badge.png plus <out>/index.json (club ->
source URL). nrl.com has no Super League data, and superleague.co.uk only
serves 400px crests, so this is the HD source for the British clubs.

Usage:
    python tools/gol_logos.py resources/gallery-of-league-logos
"""

import json
import os
import re
import sys
import urllib.request

INDEX = "https://galleryofleague.com/british-rugby-league-history/"
UA = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/126 Safari/537.36"}

# (section, [(club folder, logo filename prefix)]) in page order. The logo
# filenames carry no section, so the index page's own order is mirrored here.
SECTIONS = [
    ("super-league", [
        ("bradford-bulls", "Bradford_Bulls_Logo"), ("castleford-tigers", "Castleford_Tigers_Logo"),
        ("catalans-dragons", "Catalans_Dragons_Logo"), ("huddersfield-giants", "Huddersfield_Giants_Logo"),
        ("hull-fc", "Hull_FC_Logo"), ("hull-kr", "Hull_KR_Logo"), ("leeds-rhinos", "Leeds_Rhinos_Logo"),
        ("leigh-leopards", "Leigh_Leopards_Logo"), ("st-helens", "StHelens_Logo"),
        ("toulouse-olympique", "Toulouse_Logo"), ("wakefield-trinity", "Wakefield_Trinity_Logo"),
        ("warrington-wolves", "Warrington_Wolves_Logo"), ("wigan-warriors", "Wigan_Warriors_Logo"),
        ("york-knights", "YorkRLFC_Logo"),
    ]),
    ("championship", [
        ("barrow-raiders", "Barrow_Logo"), ("batley-bulldogs", "Batley_Bulldogs_Logo"),
        ("dewsbury-rams", "Dewsbury_Rams_Logo"), ("doncaster", "Doncaster_Logo"),
        ("goole-vikings", "GooleVikings_Logo"), ("hunslet", "RL_Menu22_Hunslet"),
        ("keighley-cougars", "Keighley_Cougars_Logo"), ("london-broncos", "London_Broncos_Logo"),
        ("midlands-hurricanes", "Midlands_Logo"), ("newcastle-thunder", "NewcaslteThunder_Logo"),
        ("north-wales-crusaders", "Crusaders_Logo"), ("oldham", "Oldham_RLFC_Logo"),
        ("rochdale-hornets", "Rochdale_Hornets_Logo"), ("salford-red-devils", "Salford_Red_Devils_Logo"),
        ("sheffield-eagles", "Sheffield_Eagles_Logo"), ("swinton-lions", "SwintonLions_Logo"),
        ("whitehaven", "Whitehaven_Logo"), ("widnes-vikings", "Widnes_Vikings_Logo"),
        ("workington-town", "Workington_Town_Logo"),
    ]),
    ("other-clubs", [
        ("cornwall", "Cornwall_Logo"), ("coventry-bears", "Coventry_Bears_Logo"),
        ("featherstone-rovers", "Featherstone_Rovers_Logo"), ("all-golds", "AllGolds_Logo"),
        ("halifax", "Halifax_RLFC_Logo"), ("harlequins", "Harlequins_Logo"),
        ("hemel-stags", "HemelStags_Logo"), ("london-skolars", "London_Skolars_Logo"),
        ("paris-saint-germain", "Paris_Saint_Germain_Logo"), ("south-wales-ironmen", "SouthWales_Ironmen_Logo"),
        ("toronto-wolfpack", "Toronto_Wolfpack_Logo"), ("west-wales-raiders", "WestWales_Raiders_Logo"),
    ]),
    ("international", [
        ("great-britain", "GB_Logo"), ("england", "England_Logo"),
        ("scotland", "Scotland_Logo"), ("wales", "Wales_Logo"),
    ]),
]


def get(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60).read()


def main():
    out = sys.argv[1]
    html = get(INDEX).decode("utf-8", "ignore")
    urls = re.findall(r'src="(https://galleryofleague\.com/wp-content/uploads/\d{4}/\d{2}/([^"/]+\.png))"', html)
    index = {}
    for section, clubs in SECTIONS:
        index[section] = {}
        for club, prefix in clubs:
            match = next((u for u, name in urls if name.startswith(prefix)), None)
            if not match:
                print(f"{section}/{club}: no logo starting {prefix!r} on the index page")
                continue
            dst = os.path.join(out, section, club)
            os.makedirs(dst, exist_ok=True)
            with open(os.path.join(dst, "badge.png"), "wb") as f:
                f.write(get(match))
            index[section][club] = match
            print(f"{section}/{club}: {match.rsplit('/', 1)[1]}")
    with open(os.path.join(out, "index.json"), "w") as f:
        json.dump(index, f, indent=2)


if __name__ == "__main__":
    main()
