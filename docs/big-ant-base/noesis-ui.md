# NoesisGUI front end and HUD

## How a screen is built

Most menus and the newer HUD pieces are NoesisGUI: WPF-style XAML in the `xamls` bundle
(`noesis/workspace/views/**`, styles and themes under `resources/`), fonts in the `fonts` bundle. Some older
screens and HUD elements still use Big Ant's earlier widget system (`uicore`, `*_layout.lua`).

A screen is a XAML view plus a Lua view model:

```lua
ns.Class("NVMLadderRow", ViewModel, function(self, ...) ... end).Bindings = {
    Namespace = "Workspace.ViewModels.Competition",
    Properties = { TeamName = ns.String, TeamLogo = ns.typeOf(native.CNoesisTextureSource) },
}
```

A state loads it with `engine:getNoesis():loadViewWithVM("Workspace/Views/...", vm, layer, priority)` and calls
the view model's `update()` each frame. Setting a bound property from Lua updates the XAML. Collections are
`ObservableCollection`s of child view models.

Images are `CNoesisTextureSource`s made from loaded textures. Club logos come from the club's
`decalIdOrIcon:createTexture(decalManager, decalRender, textureManager, "<variant>")`, which loads asynchronously.
The view model polls `isLoaded()`, then wraps and unloads it (see `nvm_competitionladderrow.lua`).

Themes: competition and HUD screens swap resource dictionaries by competition (e.g.
`CompetitionTheme_RLWC`, `superleaguehudresources.xaml`).

## Limits we've hit

- **Fixed slots.** Hub screens bind a fixed number of buttons (`ButtonCollection[0]`..`[4]`); a sixth Lua tile is
  silently dropped unless the XAML gets a slot. The home screen's Extra row has a spare `NTS` slot.
- **Option menus** (`NVMOptionMenu.populateMenu`) only render ValueList, Toggle and Button rows. Value +
  CustomLeftRight rows show as dead labels.
- Some designed bindings were never wired up in stock. For example, the competition ladder's 24 px `TeamLogo`
  image was bound in XAML but never filled.
- Loading-screen team logos are point-copied natively into fixed 308x312 render targets. That size is hard-coded
  in the exe, so bigger textures alias until it is patched.
- Strings live in `strings/strings_en`/`_fr` tables (length-prefixed key/value pairs), looked up with
  `native.Localise(key)`.

## HUD

The match HUD (scorebug, player plates, interchange banners) mixes Noesis views (`hud_*` XAML,
`PlayerPlateTemplate`) and legacy widgets registered in `hud_registration.lua`. A HUD element reaches cutscene state
through `uiServices.universe.cutsceneListener`.
