# official-jersey-editing

Opens official jerseys in the Academy jersey editor, limited to the **Manufacturer** and the
**numbering on the back**. It also unlocks every number font and every jersey manufacturer for
player-made jerseys.

## Official jerseys

In an Academy club's **Uniforms** list, official kits (any kit the on-disc club database has for
that club) and licensed copies (New Licensed Uniform, `uniformEditable` 0) now open the editor.
They get the Jersey tab only:

| Group | Rows |
|---|---|
| Jersey | **Manufacturer**: the cut the kit's own design is worn on |
| Jersey (numbers) | Show number, Font (all fonts), Show leading zero, Number colour, both keylines |

Pattern, colours, logos, shorts and socks can't be changed. Delete and Rename still only apply to
non-official kits, and **Restore Official Jerseys** undoes the edits. Saving uses the normal path
(`justCommittedToAChange` → `setDirty`, then the club's custom-licensed save).

### What "Manufacturer" means here

In the game data, the stock Manufacturer row picks the whole `uniformTop` item. On an official kit,
that item carries the printed design (`colTexture`), so switching it would replace the pattern.
Instead, an official kit's Manufacturer picks a **cut**: the jersey mesh (`top_round05`,
`top_vneck01`, ...) plus its seam normal/material maps (`m_top_raglan_round_03`,
`m_top_setin_round_01`, ...). The kit keeps its own design texture, clash colours and number
placement. The number is composited in texture space, so its placement follows the design, not
the mesh.

- 82 cuts (61 male, 21 female) are listed in `UniformTopTemplates`, generated from the stock
  items by `generate.py`. Each row is the lowest-guid stock item with that mesh + maps.
- Maps named after one kit (`m_top_seaEagles_nrl_home_25_nrm`, `m_top_maroons_...`) are left out,
  because they carry that kit's embossed pattern. Referee (tucked), polo, jacket, shirt and blouse
  tops are left out too.
- Entry #1 is the design's own cut. Cuts identical to it and cuts for the other sex aren't listed.
- Storage: the cut's row index is stored in `uniformTop_layer6_colour_r`, the Academy collar's
  second tint. A top with its own design has no collar layer, so the field is unused (0 on all
  749 stock kits that store it). Colour options read back as 0-1 in Lua and are stored as a byte;
  the resolver probes which once (`setOption(…, 2)` on a scratch config) and encodes to match.
- Rendering: `getUniformTopVariant(item, teamCfg)` returns a cached copy of the design item with
  the cut's fields. It's called from `var_0_27` (every top texture layer and number offset) and
  from `getModelFileNameByGuid` (the mesh), both in **jesse-southwell-hair's assetmap.lua**, which
  owns that file. The block is marked `official-jersey-editing`. Without that override, official
  kits get the number rows only.

The stock Rugby League tops share one UV layout (see `memory/character-mesh-formats`), which is why
a design can be worn on another cut. Collars and seams that the design paints may not line up
exactly with another cut's geometry.

## Keeping edits to official kits

The game restores an official club's own kits (the ones its on-disc data has) from the disc
when the profile loads, so edits to them were lost on a restart even though leaving the club
saves it (`saveCustomLicensed`). Stock never let these kits be edited, so nothing kept them.

So the jersey editor also keeps them itself: leaving an edited official kit writes the options
that differ from the disc kit (every `options.team` option, compared with
`universe:getClubDatabaseOnDisc():getClub(id)`'s kit of the same name) to `official_kit_edits.lua` in the game
folder, keyed `"<club id>|<kit name>"`. `partymember_aide.setupAcademyData` puts them back
after `runOnAllMixins("setAcademyData")` (on a copy of the club, then `saveCustomLicensed`).
Not earlier: until setAcademyData the club manager has no custom-licensed store, and a club
lookup then crashes natively (null dict at exe 0xa8d1d9), which pcall can't catch.
Changing a kit back to its disc look removes its entry. Delete the file to drop every edit.
The log (`occasion_text_debug.txt`) says how many options each club had and how many the load
had reverted ("N restored").

## Name on the back

Both official and player-made jerseys get a **Name** group on the Jersey tab (stock only had these
rows in the artist debug group):

| Row | Option |
|---|---|
| Show name | `hasPlayerName` |
| Font | `playerNameFont` (all 22 name fonts) |
| Name colour / Name keyline weight / Name keyline colour | `nameColour1_*`, `nameKeylineWeight`, `nameKeylineColour1_*` |
| Name placement | placed like a logo (see below) |

The text is each player's **Jersey Name** (identity), drawn by the stock text layer in
`uniformNumberLayers` (186 stock kits already show names). Its box is fixed in UV space
(x 0.22-0.78, y 0.45-0.55), moved and scaled vertically by the top's `nameOffset`. The kit's
placement applies on top of that: up to ±0.3 across and ±0.45 up/down (enough to put the
name above the number), 40% to 300% size. Size also widens the box around its centre, because
the text fits the smaller of width and height, so a long name wouldn't grow otherwise.

## Placement with the sticks

**Name placement** and **Chest text placement** work like a logo's position. Press A on the row,
then:

- left stick / d-pad moves the text
- right stick up/down makes it bigger/smaller
- L3 puts it back to the stock placement
- B finishes

Choosing the row also switches the name / chest text on. `updateTextPlacement` (edit groups)
runs the mode: the row is `createDecalModifier` with its own `onActivate`, which sets
`previewMode`, and the jersey edit state hands it the frame instead of the stock (unused, wrongly
called) `updateDecalPreviewMode`. A failure leaves the mode and is logged to
`occasion_text_debug.txt`.

Storage: **new team options** (`AppendJerseyTextOptions` in jesse-southwell-hair's assetmap.lua,
added after the decals, the same way the stock decal options are added): `modNamePosX/Y/Scale`
and `modChestPosX/Y/Scale` (2-byte guids holding v × 10000), `modChestText` (guid, 0/1),
`modChestColour1_*`, `modChestKeylineColour1_*` and `modChestKeylineWeight`. The placement
was first kept in 0-1 slider options (`modNameX/Y/Scale`, `modChestX/Y/Scale`, still
registered so old configs load), but those came back reset after a save while the on/off guid
kept its value, so it moved to guids. A placement of 0 means the stock placement, which is
also what a kit saved without these options reads. Otherwise x/y = (v - 0.5) × 2 × range and
size = min × (max / min)^v; the editor keeps v at 0.001 or above. Opening the editor logs the
stored values to `occasion_text_debug.txt` ("editor opened: ...").

## Chest text (special matches)

Like the commemorative text on NRL grand final and milestone jerseys, e.g.

    NRL TELSTRA PREMIERSHIP GRAND FINAL
    BRONCOS V PANTHERS
    3RD OCTOBER 2023, SYDNEY

A **Chest text** group on the Jersey tab (official and player-made kits) has **Chest text
(special matches)** (on/off, **on by default** for every kit), **Chest text placement** (sticks:
±0.15 across, ±0.35 up/down, 50% to 500%), **Chest text colour**, **keyline weight** and
**keyline colour** (no keyline by default). **Chest text auto colour** (on by default) prints
black or white to suit the jersey: designed tops use `OccasionTextBlackTops` in assetmap.lua,
written by `chest_colours.py` (it samples every top's texture under the default box and picks
black where that beats white for contrast, linear luminance > 0.179; 419 of 841 tops), and
Academy tops use their base colour. Picking a colour in **Chest text colour** turns auto off.
Re-run `chest_colours.py` after installing new kits. By default the block is small and centred
on the chest, between the NRL logo and the club crest at the level of their captions
(x 0.375-0.429, y 0.343-0.367; checked on the Broncos, Panthers, Dolphins and Cowboys tops).

**Font: RL Font** (the NRL's typeface), always. The exe only loads its own font files, so
`rl_font.py` writes RL Font Bold, renamed to the family `Font`, over `arvo-bold.ttf` (the
`UniformArvoBold` jersey name font: no stock kit or menu uses it), and the chest text layers ask
for `UniformArvoBold`. Side effect: a kit choosing the Arvo Bold name font prints names in RL Font.
The generated file (`noesis/workspace/fonts/arvo-bold.ttf`) is committed and ships with the
mod. Re-run the script (it reads RL Font from the fonts installed on this PC) only to change
the weight, then build the **fonts** bundle (`manifests/fonts.xml`). While editing, the kit shows a sample
(`<club> V OPPONENT`, today's date). In matches, nothing is drawn unless the match is special:

- **Grand final:** a career or competition grand final fixture
  (`stateOfTheSeason.isGrandFinal` / special event), or the NRL or Super League grand final
  field markings (Play Now's Grand Final match uses them). Every jersey of a kit with Chest
  text on shows: the title by competition (NRL, NRLW, Super League, Women's Super League,
  Hostplus Cup, or plain "GRAND FINAL"), `HOME V AWAY` (club nicknames), and today's date with
  the ground's city.
- **Milestone game:** a player's 100th, 150th, 200th ... game (`getLifetimeStats`
  `matchesPlayed` + 1, as the try HUD counts it). That player's jersey shows
  `<FULL NAME> - <N> GAMES`, the teams and the date. Players are matched by Jersey Name.

`matchin.finalise` (in **nrl-special-balls' matchin.lua**, marked block) puts the words in
`_G.MOD_OCCASION_TEXT`. The front end clears it on entry (`frontend_state.lua` override) and
the jersey editor uses `_G.MOD_OCCASION_TEXT_PREVIEW`. While `OCCASION_TEXT_DEBUG` is on, it
logs to `occasion_text_debug.txt` in the game folder. The date is the real-world date (`os.date`),
not the career calendar.

Drawing: three text layers appended to `uniformTopColourLayers` (after the decals), so the text
is part of the top's colour texture, not the back number plate. The chest window was measured
from the meshes (`tools/bigant_mesh.py`): the stock layout's front panel is centred on x 0.401
with the upper chest at y 0.33-0.42, and `top_round06`/`07` are remapped to their own layout.
The top colour texture's shared param gets `getOccasionTextHashKey` appended, so jerseys
showing text get their own composite and kits without it keep sharing as before.

**Placement test** (session only, `_G.MOD_OCCASION_TEXT_MODE`): the texture's y direction and
the text's rotation for this target aren't confirmed. 1 = upright (expected), 2 = upright
turned 180°, 3 = flipped vertically, 4 = flipped and turned. Remove the row once one is
confirmed.

## Player-made jerseys

- **Manufacturer** lists the 10 Academy cuts plus every designed top on a jersey mesh (official,
  legacy and modded kits). Holding left/right speeds up the scroll. Picking a designed top uses that
  design as-is (the colour/pattern rows have no effect on it) and resets the cut index (so a
  collar colour left in `layer6_colour_r` isn't read as a cut). Switching back to an Academy cut
  leaves Top colour 6's red at 0.
- **Font** (numbers) lists every font. Stock hid guids 1, 3, 4 and 5: the NRL, QLD, NSW and Super
  League logo fonts, which 482 stock kits use.

## Files

- `src/script-game/app/academy/academy_club_jerseystate_appearancestate_edit_groups.lua`: the
  unfiltered lists, the restricted `LicensedGroupList`, `OfficialKitEditing = true`.
- `src/script-game/app/academy/academy_club_jerseystate_appearance_state.lua`: sets
  `officialUniformEdit` on the club view info for the kit being edited.
- `src/script-game/app/academy/academy_club_jerseystate_appearancestate_edit_state.lua`: uses
  `LicensedGroupList` when that flag is set (stock hard-coded `false`), and runs the stick
  placement mode.
- Hooks in other mods' overrides (no-ops without this mod's edit groups):
  - copy-academy-jerseys `academy_club_jerseystate_list_state.lua`: official kits are `editable`
    when the club can be edited and `OfficialKitEditing` is set.
  - jesse-southwell-hair `design/characters/assetmap.lua`: the `UniformTopTemplates` block and
    the resolver, the text placement options, the name window, and the chest text layers and hash key.
  - nrl-special-balls `app/match/matchin.lua`: the chest text for each match (finalise).
- `rl_font.py`: RL Font into the Arvo Bold font slot (see Chest text).
- `chest_colours.py`: black/white chest text per designed top.
- `src/script-game/app/frontend/frontend_state.lua`: clears the match's chest text when the
  front end starts again.
- `src/script-game/app/frontend/partymember_aide.lua`: `saveOfficialKitEdits` /
  `applyOfficialKitEdits` (see Keeping edits to official kits).

`python mods/official-jersey-editing/generate.py` rewrites the template block. The list is
append-only: kits store row indices, so existing rows keep their place.

Status: built 2026-10-30, not yet tested in game (stick placement, new options and chest text included).
