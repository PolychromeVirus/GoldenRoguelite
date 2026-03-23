# Golden Roguelite — TODO & Design Reference

## Near-Term Polish

### Visual & Audio Polish Pass *(in progress)*
Full timing + audio audit to make combat feel satisfying. Existing: enemy hit/hurt/death animations, player flash, status inflict feedback, damage numbers. Needs audit:
- Damage number delays and sequencing (stagger, pop timing)
- Sound effects for all combat actions (attack, spell cast, djinn unleash, status inflict, heal, death, level up, etc.)
- Spell/djinn cast animation hooks (where to fire, what to show)
- Djinni unleash animations (per djinn or per element)
- Battle item use animations
- Turn transition feel (delay between actions)
- Review all `MakeTurnDelay` values for pacing

### ✅ UI Pass — Menu Stack & Input Parity
All in-game menus use PushMenu/PopMenu and support mouse + keyboard. Known remaining gap: keyboard nav on CharacterSelect (non-blocking, deferred).

### Monster Stat Viewer
- Click/hover on a monster in combat to see its stats (HP, ATK, DEF, weaknesses, resistances, status effects, etc.)
- Design TBD (tooltip, popup, sidebar?)

### Carousel Live Data
- objMenuCarousel currently receives a static items array that can go stale (e.g. djinn trade modifies the backing array mid-draw)
- Refactor: pass `{ source_player, source_field }` so carousel reads from `global.players[source_player][source_field]` each frame
- Formatter callback (e.g. `item_builder(index)`) converts raw data (djinn ID, spell ID, etc.) into display structs on the fly
- Filter/on_confirm callbacks work the same but always see current data

---

## Near-Term Mechanics

---

## Milestone Features

### ✅ Logging/Output
Persistent `global.log[]` with scrollable `objLogViewer` overlay (G key), file output to `log.txt`, tooltip bar still shows most recent entry.

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
- ✅ Boss status resistance (status_resist cap + status_immune flag)
- ✅ Full djinn roster
- ✅ Armor breaking
- ✅ Difficulty/curse stack system
- ✅ Boss reward picker
- ✅ Silent discard / shop inventory growth
