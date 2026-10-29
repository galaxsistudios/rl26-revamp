# wayne-bennett-coach

Adds Wayne Bennett as a coach, using an AI-generated face texture
(`wayne_bennett_face.png`). He takes over generic NPC **503 "Paddy Douglas"** and that NPC's
tier-1 head slot, so nothing is appended and no Lua or `global.texsrc` change is needed.

## How it works

- **Every tier-1 head (player or coach) uses the same UV layout** (3226 verts). Any face
  texture fits any head mesh once its features sit where the template expects them.
  `face_warp.py` closes the source's open mouth, then thin-plate-spline warps it onto the
  template. The source's face sat about 90-145 px too low (in 1024 px) and was about 35% too long.
- **Head mesh:** Peter Gough's scan (long, lean face) is byte-copied over Paddy's head and
  hair-cap meshes. Model blobs carry no names. Gough was picked from renders of 12 scans
  wearing this texture. For tier-1 heads every hair or beard mesh is simply `head + 1000` if
  that item exists. Paddy's head has no beard meshes, so Bennett is clean-shaven.
- **Hair:** the first install used Betts' full 3D crop, which hid the painted balding crown.
  The hair-top and hair-side meshes are now installed with every triangle made degenerate
  (all indices 0), and the hair cap uses the `haircap_balding01_col` pattern
  (`hairTexture_cap` = 1: thin sides, bald crown), tinted grey.
- **Textures:** `_col` = the warped face (uncompressed BGRA, 2048/1024/512 like stock).
  `_nrm` / `_mat` = Gough's maps, because they're baked from the same mesh. They are installed
  with texture_mods' Mini_TXPK layout, which keeps Paddy's header and path.
- **NPC record** (entry 39954): `defaultdata/defaultdata_npcs/000503_Bennett.json` does a
  same-length rename (Paddy Douglas -> Wayne Bennett), sets `npcType` to Coach, and sets the
  hair/beard colours to grey 1000 (`visual` patches, see `tools/parse_npcs.py` `visual_layout`).
  `defaultdata/000503.npcdata` is the same visual, written by `install.py build`.

## Install (game closed)

```powershell
python mods\wayne-bennett-coach\install.py build
python mods\wayne-bennett-coach\install.py install --confirm   # 17 entries, pack.py backups
# then rebuild 39954 from a STOCK extraction (it's shared with unhide-coaches / leagues mods):
python tools\pack.py restore --entry gamedata
python tools\extract_m3mp.py --entry gamedata --out <tmp>
python tools\build.py full --list manifests\gamedata.xml --extracted <tmp> --out _build\gamedata.m3mp --confirm
```

Undo: `install.py restore`, then rebuild 39954 without this mod.

## Test

Academy > Coaches (coach-editor) should list Wayne Bennett. Assign him to a club. With
team-coaches installed he then appears on the sideline in grey hair and the club polo.

Things to check:
- whether the balding hair cap sits well over the painted grey sides;
- seams at the back of the scalp (the warp leaves the source's side and back hair in place);
- the eye area (eyeballs are separate meshes; the texture's eye holes sit under them).

Tuning: change the landmarks in `face_warp.py`, or `hairColour1` (guids from
`ItemMaps.hairColours`: 99 = near white, 1000-1011 = greys light to dark), then re-run `build` +
`install --confirm` (+ the 39954 rebuild for colour changes).
