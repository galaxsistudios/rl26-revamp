# loading-screen-secondary-arrows

On the team loading screen (home vs away), every second chevron arrow on each side is drawn in the
club's secondary colour (primary, secondary, primary, ... from the centre out). Stock draws them all in
the primary colour. Background glows and gradients keep the primary colour.

| Files | Entry |
|---|---|
| `src/script-game/design/loading_setup_helper.lua` | 39959 (scripts) |
| `noesis/workspace/views/loadingscreen/loadingscreen_rugby.xaml` | 57662 (Noesis XAML) |

Both files are generated. Edit `generate.py`, not the outputs:

```powershell
python mods\loading-screen-secondary-arrows\generate.py
```

## How it works

The loading screen's view model is native (`paNVMGameplayLoadingScreen`). It only binds
`HomeTeamColour`, `AwayTeamColour` and the two images, and `CTeamLoadingScreenData` has no field for
a secondary colour. So the colour carries the information itself:

- **Lua** (`SetupLoadingScreen`): sends each side's primary with the low 2 bits of every channel
  replaced by a 6-bit hash of the secondary (at most 3/255 off, not visible). That makes the colour
  unique per (primary, secondary) pair. Broncos and Manly share a primary but get different keys.
- **XAML**: `HomeSecondaryArrow` / `AwaySecondaryArrow` styles map each stock club's key colour to its
  secondary with a `DataTrigger` (87 pairs, generated from `defaultdata_clubs` plus any club overrides
  under `mods/`). The stock arrows 2/4/6 use those styles.
- Each 1s `GlowyLines` cycle moves every arrow one slot outward and then resets, so fixed per-slot
  colours would make every arrow change colour at the reset. A copy of each side's arrows (following
  the stock thickness, opacity and margin) has the opposite pattern (1/3/5 secondary), and the
  `SecondaryArrows` storyboard swaps the stock arrows and the copy at each reset. Each arrow keeps
  its colour as it travels outward.

The generator exits if two pairs hash to the same key. If that happens, change `HASH_MULS`.

## Limits

- Custom/user-edited clubs, or a stock club with edited colours, have no table entry, so their arrows
  stay primary (the stock look).
- Online and pro-team lobbies go through `SetupLoadingScreenFromSideInfo`. That path only networks
  the primary colour, so it is left unchanged.

## Bigger, sharper team logos

`generate.py` also enlarges the team logos from 542x550 to 680x688 (`LOGO_SIZE`) in a 1700x700 `LayoutGrid`
(stock 1500x550), and makes `SetupLoadingScreen` load icon clubs' `ui/club_logos/large_mirrored/<icon>.texture`
directly (`LogoTexture`; custom decal clubs still use `createTexture`). The sharpness comes from
[hd-nrl-club-logos](../hd-nrl-club-logos/README.md): its 1232x1248 textures plus the exe patch that enlarges the
native 308x312 copy target. Without that mod the stock logos are just stretched further.

## Scrolling outline VS

The two static outline "VS" copies behind the solid "VS" are replaced by a column of outline copies spaced
70px apart (`VS_SPACING`, the stock gap), at opacity 0.12 under a top/bottom fade mask. The stock `vsAnim`
storyboard (empty, 4s, `RepeatBehavior="Forever"`, already started on `Loaded`) now slides the column down
by 4 spacings (`VS_STEPS`) every cycle, so the loop is seamless.

## Competition background logo

Behind the team logos, a 560x560 competition logo (`CompetitionLogo`) appears at 0.25 opacity as soon as the
competition is known. It then breathes down to 0.1 and back over 3s each way, forever (`COMPETITION_OPACITY`,
`COMPETITION_OPACITY_LOW` and `COMPETITION_BREATHE` in `generate.py`). The animation starts from each logo's own
DataTrigger (`EnterActions`), so it always begins at the top of the cycle. A root `Loaded` storyboard would run
ahead of the key. The logos are the game's own 1080x1080 `Images/logos_competition/1080/*.png`,
mapped from a `CareerCompetitionIdEnum` name (`COMPETITION_LOGOS`). Each logo is its own `Image`, with its
`Source` set directly and its `Visibility` switched by DataTriggers. A relative `Source` set through a Style
`Setter` has no base URI and never loads.

**Preloading (`install.py`).** A static image `Source` only shows textures the engine has preloaded from the view's
`<view>.texpack`. The stock `noesis/workspace/views/loadingscreen/loadingscreen_rugby.texpack` (entry 57807) is
an empty 8-byte placeholder with no blob file. `install.py install --confirm` fills it with the 15 logos (17.5 MB),
copied from the standalone `.texture` entries. The screen-wipe texpacks use the same format. The installer's
`textures` step runs it.

**Getting the competition to the XAML:**
- The view model only has team colours and images. `CTeamLoadingScreenData.theme` is a dead end: Lua can set it,
  but nothing native copies it to the view model's `BackgroundLogoTheme`.
- The loading screen's string `m_loadingText`, set via `getLoadingScreen():setLoadingText()`, is unused by this
  XAML, so it carries the key.
- The competition is only known after `matchin.finalise`.
  [nrl-special-balls](../nrl-special-balls/README.md)' `matchin.lua` calls `MOD_LOADING_COMPETITION_HOOK` there.
  `competitionId` is an enum value, and the key is its name, found by matching string keys only: the enum table
  maps both ways.
- `SetupLoadingScreen` sends whatever key is already known. Career spectate finalises before it.
- `matchsetup_lockdown.lua` clears the key at the start of each match.

**Which logo.** The key is the first candidate that has a logo. Keys with no logo fall through, so a normal
Friday-night markings setting never hides the club guess. The candidates, in order:
1. Play Now's round pick (`MOD_FIELD_ROUND_ACTIVE` from enable-casual-fieldmarkings), e.g. `Round_allstars`,
   `Round_pacific`.
2. The competition, from career, competition mode or a Play Now `casualMimicSeason`.
3. The field markings setting, e.g. `Markings_NRL_Rep_AllStarsMatch`, `Markings_NRL_Rep_AnzacTest`.
4. The club guess made in `SetupLoadingScreen`:
   - by club icon: NSW v QLD (`ORIGIN_ICONS`) is Origin, `soow_*` sides are women's Origin, and Indigenous /
     Maori / All Stars (`ALLSTARS_ICONS`) is All Stars. These sides only sit in the shared "NRL REPRESENTATIVE"
     league, so no league can single them out;
   - otherwise the first `native.AcademyLeagues` league in `CLUB_LEAGUES` that holds both clubs
     (`getLeagueIdsContainingClub`). For example, the QLD Cup sides are in `League_QLDCup2026` ("HOSTPLUS CUP (QLD)").

**Logos the game doesn't ship** (`NEW_LOGOS`) are rendered by `install.py` into the texpack as 1080x1080
premultiplied BGRA, with no standalone entry:
- Pacific Championships and Telstra Footy Country Round, from `resources/field-markings/field-centers`;
- NSW Cup, from the NSWRL vector badge;
- the men's and women's Origin shields, cropped from the stock Origin logos (`stock:<logo>@<rows>`) without
  the Ampol bar and the text.

`DEBUG = True` in `generate.py` writes `loadingscreen_debug.txt` to the game folder and shows `m_loadingText`
on screen.

## Team logo slide-in

Each time the screen comes up after Play, both team logos slide out from the screen centre to their columns
(510 units in the 1080p layout, `LOGO_SLIDE`) over 1.4s (`LOGO_SLIDE_TIME`, cubic ease-out), fading in over
0.8s. It animates `Margin`: a margin of (d, 0, -d, 0) shifts a logo by d. Animating the logo's `RenderTransform`
did nothing in-game. The trigger is the competition key. `SetupLoadingScreen` clears `m_loadingText` and sets it
again, so it always changes, and each logo has an enter trigger for every `COMPETITION_LOGOS` key. The stock
`IsLoaded` and `m_showMain` signals didn't fire at the right time. A match with no competition key doesn't slide.

## Stadium background

The match's ground shows at 10% opacity (`STADIUM_OPACITY`), above the blurred team logos and below the arrows.
The Lua works out `"<stadium>_<day|night>"` in the finalise hook:
- the stadium from `matchInData.groundInfo.groundInfo.stadium`;
- the time of day from `matchInData.timeOfDay`, which is the kickoff hour. It is converted with matchin's
  `getTimeOfDayFromHour`. Morning, day and afternoon use the day photo; dusk and night use the night photo.

The key goes to the XAML through `m_tipsText` (`getLoadingScreen():setTipsText()`, unused by the stock rugby
XAML), and one `Image` per key is shown by a DataTrigger. `install.py` preloads every shipped
`ui/textures/stadium_images/<stadium>_<day|night>` (`stadium_keys()`, 183 images from 91 grounds) into the
texpack, cut down from 1120x740 BGRA to 640x424 DXT1 (`STADIUM_SIZE`, ~136 KB each, ~25 MB).

A texture loaded by Lua's `textureManager:load` is NOT shown by a bound or static `Source`; only texpack members
are. All five times of day at full size would be ~1.5 GB.
