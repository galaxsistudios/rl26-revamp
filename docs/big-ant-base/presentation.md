# Match presentation

## Cutscenes

- Cutscene data is Lua (`intermediatelua/cutscenes/data/*.lua`) plus animation sets. Sequences and weighted
  groups live in `cutscenedata_config` (`SequenceList`, `GroupList`) and are resolved with the match seed, so
  they're random per match but the same across preload and playback.
- The intro sequence is chosen in `rules/cutscenes/initial_cutscene.lua` (regular, finals, GF, anthem variants)
  and played by `TeamShieldRuleState`. A cutscene lasts as long as its longest actor animation.
- Some shipped content is never used: cheerleader try cutscenes, injury cutscenes, trailer corridor walks, locker
  room camera tracks and several referee signals.
- **Lighting**: `lightingScenes` name files in `intermediatelua/lighting/`. The lighting module re-imports them on
  every cutscene start, so lights can be recoloured per match from Lua.
- **Particles**: props with an `fxFile` (Effekseer `.efk` effects) fire on `ParticleEvent`s.
  `effectLocator_01` is an invisible emitter.

## Replays and transitions

A try queues its replay at the start of the celebration, and the replay is pushed at the next barrier. Barriers
are screen wipes (`base/transition/screenwipe.lua`) or the RL26 logo wipe (`LogoScreenWipeOut`), which ends a
try replay. Replay moments are picked one at a time in priority order (video ref > ball strip > knock-on > ...),
so only one plays per stoppage.

## HUD and broadcast

The scorebug, player plates, interchange and sin-bin banners and the team stinger
(`services.hud:getElement("logotransition")`) are HUD elements, themed per competition (NRL uses the default
theme). The loading screen's view model is native: team colours and images, plus one per-match string.

## Sound and music

Try music goes through `SoundListenerIngameMusic` (`startCelebrationMusic`), and field goals reuse the try flow.
Commentary is keyed by hashes on clubs (location, mascot) and players (`commentaryNameHash`).
