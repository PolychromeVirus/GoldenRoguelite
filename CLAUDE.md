# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GameMaker Studio 2 roguelite adapting the "Lighthouse Dash!" board game (Golden Sun-inspired dice pool combat). GMS2 2.3+ with functions, structs, and method syntax. Screen resolution: 1536px wide.

Naming convention documentation in the "notes" folder, check there for variable names in main structs, document new features here

## Build & Run

This is a GameMaker Studio 2 project (GoldenRoguelite.yyp, IDE version 2024.14.3.217). There is no CLI build, test, or lint system — all building and running is done through the GMS2 IDE. Code is GML (GameMaker Language).

## Architecture

### Data Pipeline
CSV files in `datafiles/` → `InitGlobal()` loads them into global arrays → merged into `global.itemcardlist` (weapons + items + armor). All item/equipment indices reference this merged array.

Global arrays: `global.weaponlist`, `global.itemlist`, `global.armorlist`, `global.itemcardlist`, `global.psynergylist`, `global.djinnlist`, `global.monsterlist`, `global.troops`

### Dice System (core mechanic)
- `CreateDicePool(player)` → sets die counts from weapon + djinn + element
- `RollDice(player)` → returns 5-element array `[melee[], venus[], mars[], jupiter[], mercury[]]` of pip values 1–6
- `GetChargedDice(player)` → returns `{charged_map, charged_count}` — **only for rendering per-die state**
- `QueryDice(player, subset, mode)` → returns a number — **use this for ALL game logic**

Pool index macros: `POOL_MELEE=0, POOL_VENUS=1, POOL_MARS=2, POOL_JUPITER=3, POOL_MERCURY=4`

QueryDice subsets: `"all"`, `"elemental"`, `"melee"`, `"venus"`, `"mars"`, `"jupiter"`, `"mercury"`
QueryDice modes: `"affinity"` (die count), `"charge"` (charged count), `"uncharge"`, `"values"` (pip sum), `"highest"`, `"lowest"`, `"top2"`, `"charged_values"`

### Combat Flow
1. `StartCombat()` spawns `objMonster` instances from `global.troops`
2. `CreateOptions()` spawns action buttons + `objDiceDisplay`
3. Player action (Attack/Spell/Item) creates a packet struct which it mutates with the effect's damage/range/element using `QueryDice`, then passes that struct to `SelectTargets()`
4. `SelectTargets()` creates `objMonsterTarget` (enemies) or `objCharTarget` (allies) with the packet struct
5. Target confirmation applies damage/healing/effects and calls `NextTurn()`

**Critical pattern:** Outgoing damage is always calculated before `SelectTargets` — targeting objects modify *incoming* damage only (for per enemy effects such as weakness)

### Weapon Charge Rules
| Type | Charged when |
|------|-------------|
| Short Sword | pip >= 4 |
| Long Sword | pip even |
| Staff | pip >= 3 |
| Mace | pip >= 5 |
| Axe | pip appears 2+ times across entire flat pool |

Staff attacks use charged melee dice only; all others use all charged dice.

### Key Global State
- `global.turn` — index into `global.players[]`
- `global.players[]` — character structs with hp/pp/atk/def/dicepool/equipment/spells/status (See notes folder)
- `global.inCombat`, `global.pause` — flow control bools (global.pause is managed by handler that reacts to which windows are open)

### Castability Check
`isCastable` checks PP cost + player has >=1 die of the spell's element (no charged dice requirement). it also checks if a spell is provided by an item (always castable)

### Targeting Schema (packet struct)
Fields set before `SelectTargets`: `target` ("enemy"/"ally"/"none"), `num` (range), `dam`, `repeater`, `dmgtype` (element), `unleash` (struct), `onConfirm`, `splash`, `pierce`, `slash`, `caster`, `statuses`, `source` ("djinni"/"summon"/"weapon"/"item"/"psynergy")
Healing fields: `healing`, `healingratio`, `revive`, `removepoison`, `removebad`, `removebuffs`, `defup`, `atkup`, `rootTokens`, `regen`, `regheal`, `aegiscurse`, `cloak`
Status inflicts: `inflict_delude`, `inflict_sleep`, `inflict_stun`, `inflict_poison`, `inflict_venom`, `inflict_psyseal`, `inflict_haunt`, `inflict_clearstats`, `inflict_atkdown`, `inflict_defdown`

### Passive System
- `AddPassive()` pushes to player's passive queue. Struct: `{effect, countdown, sprite, source, data}`
- Key effects: `damage_cap_1`, `damage_half`, `skip_enemies`, `skip_bosses`, `_DjinnEcho`, `_Resonate`, `_mud`, `_vine`, `_melee`, `_element`

### Dungeon & Floor System
- `global.dungeonlist[]` loaded from `DungeonImport.csv`, per-dungeon troop CSVs
- `global.floorChallenges[]` — `{type, troop, completed, unique, override_name, puzzle_index}`
- Flow: `StartDungeon()` → `GenerateFloor()` → combat/puzzle challenges → `NextFloor()` → `CompleteDungeon()`
- `DifficultyUp()` increments `global.curseStacks` (hp/res/atk), applied at monster spawn

### Town System
- `EnterTown(index)` → auto-heal, repair broken armor, queue find rewards → `ProcessTownFinds()` → `objTownShop`
- `objTownShop` shows aggregated discard pile inventory + psynergy/summon specials

### Reroll System
- `player.rerolls[]` array of `{mode, uses, source, expires}`
- `objReroll` button in combat → `objRerollPicker` for partial/single selection → `RerollDice(player, selections)`

## Code Organization

- `scripts/` — ~85 script modules (GML functions). Key: `GetChargedDice.gml` (QueryDice + macros), `CastSpell.gml`, `SelectTargets.gml`, `NextTurn.gml`, `RollDice.gml`, `CreateDicePool.gml`, `UnleashDjinn.gml`, `WeaponAttack.gml`, `ProcessPostBattleQueue.gml`
- `objects/` — ~80 objects. Key combat: `objAttack`, `objMonsterTarget`, `objCharTarget`, `objDiceDisplay`, `objMonster`, `objCombat`. Key UI: `objTownShop`, `objPuzzlePrompt`, `objBossRewardPicker`, `objRerollPicker`, `objForcePicker`, `objEchoPicker`, `objResonatePicker`
- `objects/obj*/Mouse_7.gml` or `Mouse_56.gml` — confirm/click handlers (GMS2 mouse event naming)
- `datafiles/` — ~20 CSV data files (content + per-dungeon troop/recipe files)
- `rooms/` — CharacterSelect, MainGame, MainGameTester
- `notes/` — struct field references, naming conventions, passive/character TODO tracking

## Conventions

- Spell struct fields: `element, name, cost, range, targetType, stage, maxstage, base, poison, stun, sleep, delude, psySeal, ppDrain, damage, alias, text, character`
- The `damage` field in spells is a string — use `real()` to convert
- Element colors (GML BGR format): melee=`0x303030`, venus=`0x44BB44`, mars=`0x2244FF`, jupiter=`0xCC44AA`, mercury=`0xCC8800`
- `objMonsterTarget` and `objCharTarget` follow the same pattern: `selected` index, Draw GUI highlight, Confirm applies effect + calls `NextTurn()`
- Naming: `FunctionName()` (UpperCamelCase), `assAssetName` (prefixed), `_variable` (local), `MACRO` (all caps)
- `objButton3`–`objButton8` are children of `objButton2` — use `object_index == objButton2` guard in `instance_position` checks
- Struct assignment is by reference — use `variable_clone()` to avoid mutating templates
- `asset_get_index()` is case-sensitive — CSV aliases must match sprite names exactly
- Depth: menu objects at 0, tooltip text drawn at -1
- `DeleteButtons()` called at top of each menu Create to clear previous buttons
- `DestroyAllBut()` clears non-essential instances when transitioning menus
