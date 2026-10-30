# Custom kit house rules

Kits in this folder are built with [tools/kit_studio.py](../../tools/kit_studio.py) (`/design-jersey` skill).
The numbers live in [rules.json](rules.json) and the engine applies them, so changing a value there and
rebuilding updates every kit. This file is the why and the rules that can't be a number. When the user
sets a new rule, add it here (and to rules.json if it is a value).

## Artwork

1. **Real logos only.** Every sponsor, crest and badge is real artwork, taken from:
   - the game's own stock kit textures, keyed out (`{"stock": ..., "box": ...}`). This is preferred,
     because it keeps the game's own artwork and placement;
   - files the user supplies (`resources/custom-kits/sponsors/`, `logos/`);
   - the sponsor's or club's own site, or Wikipedia/Wikimedia for crests, saved into the kit's `logos/`.
   Record where each logo came from in the design.py docstring. SVGs are rasterised with
   `kit_design.rasterise_svg`.
2. **Never use an AI image, video or sound generator**, for logos or anything else. The design is
   painted by code (numpy masks) measured from photos of the real kit. The About RL26 Revamped page says
   so publicly (mods/about-rl26-revamped); keep that statement true.
3. Leave off any sponsor the user says to ignore (e.g. Betr on the Dolphins 2027), and say so in
   kit.json `notes`.

## Sponsors are laid out first

4. Every sponsor, the NRL logo and the crest is a `kit.json` entry. The engine resolves them **before**
   any design layer and gives each one its own PSD layer. Its patch or card gets a separate
   `<name> patch` layer underneath. design.py paints no sponsors. It can read `kit.sponsor_mask(part)`
   when a pattern has to stop at a sponsor.
5. Sponsor colour is white (`rules.json sponsors.default_colour`) unless the shirt or the photo says
   otherwise. Keyed logos are recoloured flat.

## NRL logo (`"rule": "nrl"`)

6. Use the official NRL Telstra Premiership logo (shield + wordmark,
   [logos/nrl_telstra_premiership.png](logos/nrl_telstra_premiership.png)), in white. Never the old badge
   with typed text.
7. It sits on a **flat patch** in the jersey's main colour, with no effects. The pattern stops at the
   patch's edge. Padding is 18 px around the shield and 7 px around the wordmark (a thicker border
   around the text looked wrong in game).
8. Keep it in from the shirt's edge. The Dolphins at 277 px from the front centre (x 1645) looked like
   it was on the edge; about 225 px is right.

## Club crest (`"rule": "crest"`)

9. About the NRL shield's height (`crest.height_vs_nrl_shield`), vertically centred on the shield, on
   the other side of the chest. A crest can carry a thin sticker border (`outline`) when the real
   shirt has one.

## Patches and cards

10. Patches and sponsor cards are flat single colours, with no gradients, shadows or glows. A logo
    patch uses the jersey's main colour, and a sponsor card the card colour in the photo (e.g. the
    white Budget Direct card).

## Design layers

11. Use one idea per layer (base, each pattern, each trim, collar, cuffs) so each can be edited
    alone in the PSD.
12. Measure from the photos. Count stripes and their spacing, and note where shapes end. For example,
    the Bulldogs alternate's chevron yoke ends in a flat line, never a point. Put the measurements in
    comments next to the constants.
13. A kit installed on another club's template (`install.templates`) keeps its own club's number
    layout with `install.numberFrom` (the Dolphins on England's `top_flat01`, numbers from 185).

## The PSD

14. `kit.psd` has three artboards (Top, Shorts, Socks), each with Design, Sponsors and Guides
    groups. Guides are never exported. Don't rename generated layers: the build matches layers by
    name.
15. Edits made in the PSD win, unless Claude is asked to change the same layer. Before changing a
    kit, run `kit_studio.py status <kit>`. If a layer you're about to regenerate was edited in the
    PSD, carry that edit into kit.json or design.py first (e.g. copy a moved logo's new position),
    or ask the user.

## Indigenous, ANZAC and other artwork kits

16. **Never generate the design of an Indigenous, ANZAC or similar artwork/commemorative kit**, not even
    by code. Those designs are artworks by real artists. Use the images the user supplies, placed onto
    the jersey template as they are (a `{"file": ...}` design layer, warped or cropped to the panels),
    and paint nothing over the artwork except what the rules below allow.
17. The sponsors, NRL patch and crest still go on top as normal layers when the ones in the supplied
    images are unclear or blurry. Where a blurry logo shows through underneath, soften (blur) the
    artwork under it, only inside that sponsor's area, so the clean logo doesn't sit on a ghost of the
    old one. Ask the user before covering anything else.
