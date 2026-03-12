# Town System + Armor Breaking — Implementation Plan

## Context
Gold currently has no use. Towns provide the gold sink (shops sourced from the discard pile), free rewards (level ups, djinn, summons, or extra draws), auto-heal on entry, and auto-repair of broken armor. The armor break mechanic adds risk/reward to powerful equipment — after each combat, breakable armor rolls a die and may become disabled until a town visit.

## Design Decisions (from user)
- **Inn**: Automatic and free — entering town fills all players to 100% HP and PP
- **Repair**: Automatic on town entry — all broken armor restored
- **Free finds**: Each town has 1-3 free rewards (levelup, djinn, summon, choice) processed before shop access
- **Shop source**: Shops pull inventory from `global.discard[]`. Purchased cards are removed from discard permanently.
- **Shop pricing**: Per-town flat prices by category (e.g. Vault: items=5g, weapons=10g). Not all towns sell all categories.
- **Psynergy shops**: Special case — 5 random learnable spells (half a draft), expensive, attempt to put at least one spell of each element if possible.
- **Summon shops**: Special case — 1 random unlearned summon, expensive
- **Silent discard**: Each `DrawCard()` call also silently discards 1 extra card to discard pile, growing shop inventory over time
- **Town access**: Always available between floors (button in overworld menu)
- **Break mechanic**: After each combat, roll for each breakable armor. On a 1 → fully disabled until town
- **Break dice**: User will add a field to Item Import csv for the break odds (8 = d8, etc)
- **Artifacts**: Deferred until multiple dungeons exist

---

## 1. Armor Breaking System

### Player struct addition
`player.broken_armor[]` — boolean array parallel to `player.armor[]`. `true` = broken/disabled.
Will be updated when trading items or using items from inventory to maintain status. Discuss this with user for a better solution.

### Break die data on armor structs
In `InitArmor()`, take in a "break_die" field from the end of the CSV, to be added. use an irandom function with the number found here -1. if field is blank, item isn't breakable.

### `RollArmorBreaks()` — new script
Called after combat victory. For each player, for each armor slot:
- If `armor.break_die > 0` and `!broken_armor[slot]`:
  - Roll `irandom(break_die - 1)`, if 0 → `broken_armor[slot] = true` + log message

### Equipment disable
In `CreateDicePool.gml` armor application loop: if `player.broken_armor[i] == true` → skip that armor entirely (no stats, no spells, no passives).
User has an idea for this, to simplify it.

### Files
- **Modify**: `scripts/InitArmor/InitArmor.gml` — add `break_die` field
- **Modify**: `scripts/CreateDicePool/CreateDicePool.gml` — skip broken armor
- **Modify**: `scripts/InitGlobalVars/InitGlobalVars.gml` — init `broken_armor[]`
- **Create**: `scripts/RollArmorBreaks/RollArmorBreaks.gml`
- **Modify**: Post-battle victory flow — call `RollArmorBreaks()`

---

## 2. Silent Discard in DrawCard

### Change to `scripts/DrawCard/DrawCard.gml`
After the main draw logic, silently discard 1 additional card from `global.deck` to `global.discard`:
```gml
// Silent discard to grow shop inventory
if array_length(global.deck) > 0 {
    var _silent = global.deck[0]
    array_delete(global.deck, 0, 1)
    array_push(global.discard, _silent)
}
```

---

## 3. Town CSV (`TownsImport.csv`) — already created by user

Format: `chapter,name,alias,effect1,effect2,wpn,arm,itm,art,psy,sum,quote`

| Field | Example | Notes |
|-------|---------|-------|
| chapter | 1 | Which dungeon chapter this town belongs to |
| name | Vault | Display name |
| alias | vault | Asset/reference name |
| effect1 | djinni | Free find: "level", "djinni", "choice", "summon" |
| effect2 | choice | Second free find (empty = none). "choice" = player picks levelup or djinni |
| wpn | 20 | Weapon price (empty = doesn't sell weapons) |
| arm | 20 | Armor price |
| itm | 10 | Item price |
| art | 25 | Artifact price (cross-chapter equipment, deferred) |
| psy | 30 | Psynergy price (5 random learnable spells at this price) |
| sum | 50 | Summon price (1 random unlearned summon at this price) |
| quote | "..." | Flavor text displayed in town (imported but not used yet)|

---

## 4. Town Data Structures

### `global.townlist[]` — loaded by `InitTowns()`
```
{
    chapter: 1,
    name: "Vault",
    alias: "vault",
    finds: ["djinni", "choice"],   // "choice" = player picks levelup or djinni
    wpn_price: 20,                  // 0 = doesn't sell
    arm_price: 20,
    itm_price: 10,
    art_price: 0,
    psy_price: 0,
    sum_price: 0,
    quote: "Welcome to Vault..."
}
```

### New globals
```
global.townlist[]           // all town definitions
global.currentTown          // index into townlist, -1 when not in town
global.townVisited[]        // town names visited this dungeon run (finds already claimed)
global.townFindQueue[]      // queue for processing sequential find rewards
```

---

## 5. Town Entry Flow — `EnterTown(town_index)`

1. Set `global.currentTown = town_index`, `global.inTown = true`
2. **Auto-heal**: All players → `hp = hpmax`, `pp = ppmax`
3. **Auto-repair**: All players → `broken_armor[i] = false` for all slots
4. Log messages for heals/repairs
5. **Free finds** (if town name not in `global.townVisited[]`):
   - Queue finds into `global.townFindQueue[]` ("choice" stubbed as regular DrawCard for now)
   - Push town name to `global.townVisited[]`
   - Call `ProcessTownFinds()`
6. If no finds (or already visited) → open shop UI directly

### `ProcessTownFinds()` — new script
Same pattern as `ProcessPostBattleQueue()`:
- Pop first from `global.townFindQueue[]`
- "levelup" → `LevelUp()`, "djinn" → `DjinnDraft()`, "summon" → `SummonDraft()`
- Draft UI dismiss calls `ProcessTownFinds()` again
- When queue empty → build and open `objTownShop`

---

## 6. Shop UI — `objTownShop`

### Build shop inventory at Create time
Scan `global.discard[]` and categorize each card. **Aggregate duplicates** — each unique item ID appears once in the shop list with a `count` field showing how many copies are in the discard pile.

- Items with `item_price > 0` → group by ID, add to shop list with count
- Weapons with `weapon_price > 0` → group by ID, add with count
- Armor with `armor_price > 0` → group by ID, add with count
- If `psynergy_price > 0` → generate 5 random learnable spells at that price
- If `summon_price > 0` → pick 1 random unlearned summon at that price

Shop entry struct:
```
{ id: <itemcardlist index>, category: "item", price: 5, count: 20, name: "Herb" }
```

On buy: decrement `count`, remove one matching entry from `global.discard[]`. When `count` reaches 0, remove from shop list.

### UI pattern (vertical carousel + objQuarterMenu)
- **Create_0**: `DeleteButtons()`, build aggregated shop list, create objHalfMenu at x = sprite_width of the halfmenuselector. Buttons: Buy (BUTTON1), Leave (BUTTON2), character switch (OPTION2-4)
- **Draw_64**: Vertical carousel. Each entry: icon, category tag, name, count (e.g. "x20"), price in gold. Grey if can't afford. Right side: description. Gold display in corner. take coordinates for text from CharSelect, as it will take up the entire vertical space of the screen.
- **Step_0**: Clamp selected, maintain objHalfMenu
- **Mouse_56**:
  - **Buy**: Check `global.gold >= price`. Deduct gold. Based on category:
    - `item/weapon/armor` → add to `player.inventory[]` (check < 5 slots), remove from `global.discard[]`
    - `psynergy` → add spell to a targeted player's `player.spells[]`
    - `summon` → add to `global.knownSummons[]`
  - Remove from shop display list
  - **Leave**: Set `global.inTown = false`, `global.currentTown = -1`, destroy shop, `CreateOptions()`
- **Destroy_0**: Destroy objQuarterMenu

---

## 7. Town Access

### `CreateOptions()` non-combat branch
Add Town button if current dungeon has towns and not in combat, and a floor challenge hasn't been attempted on this floor:
```gml
var _dun = global.dungeonlist[global.dungeon]
if array_length(_dun.towns) > 0 {
    instance_create_depth(BUTTON5, BOTTOMROW, 0, objTownButton)
}
```

### `objTownButton`
- **Mouse_7**: Resolve town names from `global.dungeonlist[global.dungeon].towns` to townlist indices
  - If 1 town → `EnterTown(index)` directly
  - If multiple → create `objTownPicker`

### `objTownPicker` (only needed for multiple towns)
- Vertical carousel of town names
- Confirm → `EnterTown(selected)`, Cancel → back to overworld

---

## 8. Files to Create

| File | Purpose |
|------|---------|
| `datafiles/TownsImport.csv` | Already created by user — town definitions with category prices |
| `scripts/InitTowns/InitTowns.gml` | CSV loader → `global.townlist[]` |
| `scripts/EnterTown/EnterTown.gml` | Heal, repair, queue finds, open shop |
| `scripts/ProcessTownFinds/ProcessTownFinds.gml` | Sequential find reward processing |
| `scripts/RollArmorBreaks/RollArmorBreaks.gml` | Post-combat break rolls |
| `objects/objTownButton/` | Overworld town button |
| `objects/objTownShop/` | Shop UI (Create_0, Draw_64, Step_0, Mouse_56, Destroy_0) |
| `objects/objTownPicker/` | Town selection carousel |

## 9. Files to Modify

| File | Change |
|------|--------|
| `scripts/InitArmor/InitArmor.gml` | Add `break_die` field parsed from text |
| `scripts/CreateDicePool/CreateDicePool.gml` | Skip broken armor in equipment loop |
| `scripts/CreateOptions/CreateOptions.gml` | Add Town button in non-combat mode |
| `scripts/DrawCard/DrawCard.gml` | Silent discard 1 extra card per draw |
| `scripts/InitGlobalVars/InitGlobalVars.gml` | Init `broken_armor[]`, `currentTown`, `townVisited[]`, `townFindQueue` |
| `scripts/Autosave/Autosave.gml` | Persist `townVisited`, player `broken_armor` |
| `scripts/LoadGame/LoadGame.gml` | Restore town/break state |
| `objects/objInit/Create_0.gml` | Call `InitTowns()` |
| `GoldenRoguelite.yyp` | Register all new scripts and objects |
| Post-battle victory flow | Call `RollArmorBreaks()` after win |

## 10. Implementation Order

1. **Armor breaking** — break_die on armor, broken_armor player field, RollArmorBreaks, CreateDicePool skip
2. **Silent discard** — DrawCard modification
3. **Town data** — InitTowns, new globals
4. **Town entry** — EnterTown, ProcessTownFinds (heal + repair + finds chain)
5. **Shop UI** — objTownShop (discard-sourced inventory, buy logic, gold deduction)
6. **Town access** — objTownButton, objTownPicker, CreateOptions integration
7. **Save/Load** — persist broken_armor + townVisited

## 11. Verification
- Equip breakable armor → win combat → check log for break rolls → verify broken armor loses all effects
- Enter town → verify HP/PP full, broken armor repaired, finds awarded once only
- Shop shows items from discard pile at correct prices → buy → gold deducted, card removed from discard
- Silent discard grows discard pile over time (more shop inventory)
- Psynergy/summon shop entries generated correctly when town sells them
- Save/load with broken armor + townVisited → verify persistence
- Town button only appears when dungeon has towns configured
