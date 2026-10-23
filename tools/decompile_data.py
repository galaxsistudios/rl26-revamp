#!/usr/bin/env python3
"""
decompile_data.py - regenerate the human-readable, per-record JSON under
decompiled/defaultdata/ for all three known packed data files (players,
clubs, leagues), from the current extracted/defaultdata/ pristine binaries.

Run this after any fresh extraction (e.g. following a game update) so the
decompiled/ JSON used for mod authoring and review matches what's actually
on disc. See data_mods.py's module docstring for how mods/ then overrides
individual records from here at build time.

Usage:
    python decompile_data.py
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import parse_players as pp
import parse_clubs as pc
import parse_leagues as pl
import parse_club_jersey as pcj


def main():
    _data, players = pp.load_players()
    n = pp.export_json(players, pp.DEFAULT_EXPORT_DIR)
    print(f"players: wrote {n} files to {pp.DEFAULT_EXPORT_DIR}")

    clubs_data, clubs = pc.load_clubs()
    club_anchors = pc.find_anchors(clubs_data)
    for idx, (club, (start, end, *_rest)) in enumerate(zip(clubs, club_anchors)):
        bound = club_anchors[idx + 1][0] if idx + 1 < len(club_anchors) else len(clubs_data)
        club["jersey"] = pcj.get_jersey(clubs_data, end, bound)
    n = pc.export_json(clubs, pc.DEFAULT_EXPORT_DIR)
    print(f"clubs:   wrote {n} files to {pc.DEFAULT_EXPORT_DIR}")

    leagues = pl.load_leagues()
    n = pl.export_json(leagues, pl.DEFAULT_EXPORT_DIR)
    print(f"leagues: wrote {n} files to {pl.DEFAULT_EXPORT_DIR}")


if __name__ == "__main__":
    main()
