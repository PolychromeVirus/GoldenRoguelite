# TODO Tracker

## Unimplemented Spells
- [x] Call Zombie — removed (Akafubu deferred to post-release)

## Djinn Stubs
- [x] Mud — reduces enemy move roll index in ExecuteMonsterTurn.gml:85
- [x] Vine — skips attempt targeting in RunEnemyPhase.gml:72

## Unimplemented Passive Effects
- [x] `_melee` — implemented in CreateDicePool.gml:46 (Kindle djinn uses it)
- [x] `_element` — implemented in CreateDicePool.gml:40 (Steam djinn uses it)

## Partially Implemented Passives
- [x] Garet/Tyrell — ATK token doubling in WeaponAttack:23; spells don't use atkmod (except Omega's matk_ratio), so no other paths needed
- [x] Mia/Rief — Healing +1 applied in both SelectTargets:43 (full-party) and objCharTarget:8 (single-target)
- [x] Ivan/Karis — Status lock applied in SelectTargets:20 for all actions via StructMerge

## Character Passives
- [x] Matthew — Knows "Retreat" (granted via CSV)
- [x] Jenna — Extra Mars die in CreateDicePool:64, auto-charged (pip=0) in RollDice:39
- [x] Sheba — Jupiter dice worth +1 in GetChargedDice:113 (values mode)
- [x] Piers — inflict_mark on attack in WeaponAttack:68
- [x] Eddy — inflict_defdown on attack in WeaponAttack:69
- [x] Kendall — Gains DEF when buffing others in objCharTarget Mouse_56 (multiple paths)
- [x] Omega — matk_ratio=1 in InitChars:105, applied in CastSpell:703
- [x] Lyza — Adds jupiter die count as damage to debuff spells in CastSpell:704
- [x] Flint/Cannon/Waft/Sleet — Reverse dice pool in WeaponAttack:35
- [x] Himi — Extra Venus die in CreateDicePool:57, auto-charged in RollDice:40
- [x] Eoleo — Items sell for 5g in objItemMenu Mouse_56:106
- [x] Sveta — +1 Melee in CreateDicePool:90
- [x] Amiti — Insight implemented in CastSpell:666 + objInsightDisplay
- [x] Jules — Jupiter dice satisfy all elements in GetChargedDice:49, damage forced to "normal" in DoDamage:9,32,174
- [x] Kai — Extra Mercury die in CreateDicePool:77, auto-charged in RollDice:41
- [x] Sean — +1 Melee in CreateDicePool:89
- [x] Ouranos — 5s become 6s in RollDice:12,16

## CSV Wiring Gaps
- [x] CharacterImport.csv columns 37-39 — `onAttackK`/`onAttackV` deprecated; passives hardcoded by name for stability. Omega `matk` handled via name check in InitChars.

## Architectural
- [x] DestroyAllBut refactor — use pushed instance IDs instead of growing object array (rendered irrelevant from menu_stack overhaul in dev branch)
- [x] Item menu "Give" — use quick character picker pattern

## Code Cleanup
- [x] Remove stale TODO comments in PassiveEffects.gml (lines 4-9) for implemented passives
- [x] Remove TODO comments on Mud/Vine cases in UnleashDjinn.gml
- [x] Update notes/character_passive_todo.md to reflect current state (deleted — superseded by TODO_TRACKER)

## Animation / UX Overhaul
- [ ] Full pass on combat animations, transitions, and visual feedback

## Controls Overhaul
- [ ] Audit all menus for mouse-only or keyboard-only input and ensure full support for both across the board

## UX — Audio
- [ ] Source Golden Sun OST rip + SFX rip and import into GMS2
- [ ] `PlayBGM(track)` wrapper — checks if already playing before restarting
- [ ] BGM zones: overworld/floor map, combat, town, boss fight, dungeon complete fanfare
- [ ] SFX: button click/confirm, cancel, damage hit, healing, status inflict, dice roll, djinn unleash, level up/card draw

## UX — Button Reactivity
- [ ] Find ways of making ui buttons reactive

