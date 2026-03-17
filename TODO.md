# Golden Roguelite — TODO & Design Reference

## Near-Term Polish

### Visual Flair Pass *(in progress)*
Animations and flash effects were partially lost during the menu overhaul. Re-add timing/visual feedback where missing. Audit:
- Hit flash on enemies
- Damage number pop timing
- Spell/djinn cast animations
- Status inflict feedback

### UI Pass — Menu Stack & Input Parity
All menus should use `PushMenu`/`PopMenu` and support both mouse and keyboard navigation. Audit every remaining menu/prompt to confirm:
- Created via `PushMenu()`
- Confirm works via mouse click AND `INPUT_CONFIRM`
- Cancel works via `objCancel` / `PopMenu()` AND `INPUT_CANCEL`
- Navigation (where applicable) responds to `INPUT_LEFT`/`INPUT_RIGHT`/`INPUT_UP`/`INPUT_DOWN`

Known exceptions (kept outside stack intentionally): `objMonsterTarget`, `objMultiKillTarget`, `objCharonPicker`, `objPuzzlePrompt`

---

## Near-Term Mechanics

### Boss Status Resistance
- `status_resist` field (column 6 in `MonsterImport.csv`) caps how many turns a status lasts on a boss
- `0` = no cap (regular enemies / unresistant bosses)
- Tick logic needs to go in `NextTurn` where status durations decrement
- One boss is fully immune — implement as a separate `status_immune` boolean (column 8, same guard pattern)

---

## Milestone Features

### Win Condition & Screen
- Define what constitutes a run completion (clear all dungeons? final boss?)
- Victory screen with run summary (floors cleared, damage dealt, etc.)
- Route back to character select or meta progression

### Meta Progression & Difficulty Scaling
- Persistent unlocks across runs (characters, djinn pool, starting options?)
- Difficulty scaling beyond current curse stack system
- Design TBD

### Remaining Characters & Gimmicks
- Implement characters not yet in the roster
- Each character's unique gimmick/passive
- Update draft pools and dungeon troop tables as roster expands


---

## Completed (for reference)

- ✅ Artifacts — weapons/armor from previous chapters, randomly upgraded, sold in each chapter's shop (only way to access items from prior chapters, including ones never drawn)
- ✅ Card descriptions pass — all weapon/psynergy/djinn text updated to match current behaviour
- ✅ Stat screen overhaul — full-screen overlay, all 4 players, PushMenu integrated (revisit: accessible from draft menus)
- ✅ Effects pass — full CastSpell/CalcPreview audit, formulas corrected, Spark Plasma redesigned
- ✅ Menu overhaul — all 7 phases, PushMenu/PopMenu stack live
- ✅ All current character passives
- ✅ Reveal (grants extra draft)
- ✅ Move (shuffles floor psynergy puzzle/trap)
- ✅ Eoleo sell passive
- ✅ Multiple dungeons
- ✅ Puzzle system
- ✅ Town system
- ✅ Reroll system (Coal/Zephyr/Lucky Cap)
- ✅ Full djinn roster
- ✅ Armor breaking
- ✅ Difficulty/curse stack system
- ✅ Boss reward picker
- ✅ Silent discard / shop inventory growth
