# nrl-field-sponsor-markings

Paints real NRL sponsor/round branding on the grass, gives each round its
own look, and makes the markings actually show up.

## What was wrong

- Every NRL sponsor bundle shipped **byte-identical** textures (Kia Tasman car
  ads, League Stars, NRL Fantasy banners), so Thursday/Friday/Saturday/... all
  looked the same.
- The sponsor layer loads with `visible = false` and only the team-shield
  intro turned it on, so it could stay hidden.
- ANZAC, Indigenous, Multicultural, Women In League and both World Cups ship
  sponsor models, but only career special events / competition ids reached
  them. Picking them as field markings loaded nothing.

## What it changes

| Part | How it's installed |
|---|---|
| `src/.../rendering/stadium/stadiumgrass.lua`: maps the extra enum values to their models, and makes the sponsor layer visible at load | `build.py full --confirm` (entry 39959) |
| 18 sponsor TXPK texture bundles (39883–39925, odd entries) | `build_textures.py` then `install.py` |
| Play Now option list (labels for the new options) | lives in `mods/enable-casual-fieldmarkings`, entry 39959 |

Sponsor models (the entry before each bundle, patched by `install.py` using
[models.py](models.py)):

- **Day badge moved to halfway.** Stock shows `leagueStars01` as two tilted
  quads near each 20 m. On the Thursday/Friday/Saturday/Sunday models (and
  their `_flipped` twins), quad A is now the NRL centre logo quad shifted to
  the opposite touchline. It's the same size and orientation, so the NRL
  shield sits on one side of halfway and the day badge on the other. Quad B
  is collapsed so it disappears.
- **Unique texture paths.** Every bundle shipped the same texture names.
  The day badge is renamed `leaguestars{th,fr,sa,su}` and the Westpac square
  `kiatasmanwp`, in both the model and its bundle. A path-keyed texture
  cache can then never show one round's art in another.

- **Grand Final.** The stock game has no Grand Final sponsor model, so
  `NRL_GrandFinal` loaded nothing. It now uses the **women's RLWC** model
  pair (39902/39904), which is geometrically identical to the men's.
  - Women's World Cup (option and tournament) now uses the men's model.
  - The centre quad is widened to 26 × 7.9 m for the wide GF wordmark,
    recoloured white.
  - Its own in-goal banners are hidden. `stadiumgrass.lua` draws the
    **Monday** model as a second sponsor layer for the GF, re-textured to
    Westpac mid-field squares and KFC in-goal banners, with its League Stars
    badge hidden. So picking Monday markings now shows just those.
  - Its centre texture is renamed `nrlgf1`; Monday's squares are
    `kiatasmanw1` / `kiatasmanwp`.
- **Full-texture UVs.** Stock quads show only a window of their texture: the
  RLWC centre maps u 0.16–0.84, and the mid-field squares crop up to 17% top
  or bottom. Those quads now map the whole texture, so replacement art isn't
  cut off at the sides.

`NRL_Round_PlayNRL` is reused as **NRL Multicultural Round** because that
round has a model but no enum value of its own.

Texture slots (sources in `resources/field-markings/`):

| Slot | On the pitch | Filled with |
|---|---|---|
| `leaguestars01` | day badge | Thursday/Friday/Saturday/Sunday logo |
| `kiatasman01` / `02` | mid-field squares | Telstra + Kia (day rounds) or Westpac (special rounds), recoloured white except Telstra |
| `wideleft/right_nrlfantasy` | in-goal banners | KFC |
| `indigenousround01`, `multiculturalround01` | centre | new round logos (Multicultural recoloured white) |

Not used yet, because no shipped model has a slot for them: Finals Series,
Magic Round, Las Vegas, Country Round. Monday, ANZAC and Women In
League keep their stock badge/centre art.

## Rebuild / install / undo (game closed)

`build_textures.py` reads the stock bundles, so restore before rebuilding.

```powershell
python mods\nrl-field-sponsor-markings\install.py restore   # undo models + textures
python mods\nrl-field-sponsor-markings\build_textures.py --texconv <path>\texconv.exe
python mods\nrl-field-sponsor-markings\install.py install --confirm
```

`texconv.exe` is from Microsoft DirectXTex releases. `pip install resvg-py`
is needed for the SVG sources. `install.py` writes the stock main/vram split
(raw header + chunk-framed payload), not `build_texture.py inject-bundle`'s
all-in-main layout, which texture_mods.py notes never loads.
