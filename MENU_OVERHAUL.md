# Menu System Overhaul — Design Document

## Context
The current menu system has ~25 individual menu/picker objects that each redundantly implement navigation, highlighting, cancel handling, and description pane creation. Adding keyboard/gamepad support requires touching each one individually. This overhaul replaces them with a small set of generic menu objects driven by config structs, unified under an explicit menu stack that manages focus and cancel automatically.

The overhaul is being done on the `MenuOverhaul` git branch. `main` preserves the pre-overhaul state as a fallback.

---

## Core Architecture

### Menu Stack
```gml
global.menu_stack = []  // array of instance IDs, top = last element
```

Two scripts manage it:

**`PushMenu(obj_type, config)`** — creates a menu instance of `obj_type` with `config` as creation data, pushes the instance ID to `global.menu_stack`, sets `global.pause = true`. Returns the instance ID.

**`PopMenu()`** — destroys the top instance, pops the array. Sets `global.pause = false` if the stack is now empty.

`objCancel` simplifies to just calling `PopMenu()` (+ cancel sound + reset `global.pendingPPCost`).
`objOptionCursor` already exits early on `global.pause = true`, so the base button row stays locked while any menu is open.

---

## Generic Menu Objects (New)

### 1. `objMenuCarousel` — Vertical list with optional description pane
**Replaces:** objPsynergyMenu, objDjinniMenu, objSummonMenu, objItemMenu, objTownPicker, objTownShop, objEchoPicker, objSummonSpellPicker, objMeldPicker, objAssignMenu, objPsynergyDraft

**Config struct:**
```gml
{
    items:         [],         // array of item display structs (see below)
    on_confirm:    function(index, item) {},
    on_cancel:     function() {},    // optional; default = PopMenu()
    description:   "none",    // "quarter" | "half" | "none"
    title:         "",         // optional header text
    filter:        undefined,  // optional function(index) -> bool; true = greyed/unselectable
    on_info:       undefined,  // optional function(index, item) {} — shows INFO button if set
    confirm_label: "Select",
    read_only:     false,      // no confirm button, cancel only (e.g. library browse)
}
```

**Item display struct** (each element of `items[]`):
```gml
{
    name:   "",    // main label
    sprite: -1,    // optional icon sprite index
    detail: "",    // optional secondary line (cost, element, damage preview, etc.)
    data:   {},    // arbitrary payload passed back to on_confirm / on_info
}
```

**Item menu pattern:** objItemMenu becomes a carousel. Selecting an item pushes an `objMenuDialog` with Use/Equip/Discard/Give options — like original Golden Sun. Removes the need for multiple bottom-row action buttons entirely.

---

### 2. `objMenuDraft` — Full-screen N-panel picker
**Replaces:** objDjinnDraft, objSummonDraft, objChoiceDraw

Screen is divided into N equal vertical slices, one per option. Used when choices are few (2–4) and each needs a large visual footprint (card art, full description visible without scrolling). Multi-phase drafts (e.g. djinn draft: pick djinn → pick adept) push a second instance onto the stack from within `on_confirm`.

**Config struct:**
```gml
{
    items:      [],        // 2–4 item display structs; screen split equally among them
    on_confirm: function(index, item) {},
    on_cancel:  function() {},    // optional; default = PopMenu()
    title:      "",
}
```

---

### 3. `objMenuGrid` — 2×2 character grid
**Replaces:** objCharTarget, objBossRewardPicker

Mouse/keyboard mode detection carries over from current objCharTarget implementation. `on_confirm(player_index)` — heal/buff/trade logic lives in the caller's closure, keeping the grid generic.

**Config struct:**
```gml
{
    on_confirm: function(player_index) {},
    on_cancel:  function() {},
    filter:     function(player_index) -> bool,  // true = greyed out / unselectable
}
```

---

### 4. `objMenuDialog` — Text prompt with 2–4 action buttons
**Replaces:** objSwapPrompt, objResonatePicker, item action submenu (Use/Equip/Discard/Give)

**Config struct:**
```gml
{
    text:    "",
    subtext: "",           // optional second line
    buttons: [             // 2-4 entries; last entry acts as cancel
        { label: "Yes", on_click: function() {} },
        { label: "No",  on_click: function() {} },  // omit on_click to default to PopMenu()
    ],
}
```

The last button in `buttons[]` is treated as cancel — fires `PopMenu()` if no `on_click` is defined.

---

### 5. `objMenuSlider` — Numeric value picker
**Replaces:** objForcePicker, objMoldPicker, objMolochPicker

**Config struct:**
```gml
{
    min:        1,
    max:        10,
    value:      1,                           // starting value
    on_confirm: function(value) {},
    on_cancel:  function() {},
    label:      function(value) -> string,   // main display text for current value
    preview:    function(value) -> string,   // optional secondary line (damage/cost preview)
}
```

---

### 6. `objMenuMultiSelect` — Togglable list
**Replaces:** objRerollPicker

**Config struct:**
```gml
{
    items:      [],                              // item display structs
    max_select: 999,
    on_confirm: function(selected_indices[]) {},
    on_cancel:  function() {},
}
```

---

### 7. `objMenuLibrary` — Full-screen rules text reference panel
**Replaces and expands:** objPsynergyLibrary

A dedicated full-screen panel showing complete rules text, flavour, and stats for a spell, item, or summon. Accessed via the INFO button on any carousel that sets `on_info`. Can be browsed with LEFT/RIGHT to step through adjacent entries in the same list. Not limited to psynergy — covers all game entities (items, summons, monsters, etc.).

**Config struct:**
```gml
{
    entries:     [],    // array of {name, sprite, full_text, stats_struct, data}
    start_index: 0,     // which entry to open on
    on_cancel:   function() {},    // default = PopMenu()
}
```

This becomes the universal "look up anything" panel — pushed via `PushMenu(objMenuLibrary, {...})` from any `on_info` handler on a carousel.

---

## What Stays Unchanged
- `objOptionCursor` + `global.option_buttons[]` — bottom button row navigation (already implemented)
- `objCancel` — simplified to call `PopMenu()`
- `objMonsterTarget` / `objMultiKillTarget` / `objCharonPicker` — combat targeting, keep as-is
- `objQuarterMenu` / `objHalfMenu` — passive visual panes; reused by carousel and draft
- `CreateOptions()` / `DeleteButtons()` — base game state button row, already refactored
- `InputPressed()` — already implemented
- `objPuzzlePrompt` — complex conditional logic (FindSpellCaster, multi-caster selection); keep as-is for now

---

## Migration Map

| Old Object | Replaced By | Notes |
|---|---|---|
| objPsynergyMenu | objMenuCarousel | on_confirm = CastSpell; on_info pushes objMenuLibrary |
| objDjinniMenu | objMenuCarousel | on_confirm = UnleashDjinn |
| objSummonMenu | objMenuCarousel | on_confirm = CastSummon |
| objItemMenu | objMenuCarousel | on_confirm pushes objMenuDialog (Use/Equip/Discard/Give) |
| objAssignMenu | objMenuCarousel | items = filtered dice pool |
| objPsynergyDraft | objMenuCarousel | per-player spell draft (vertical list) |
| objDjinnDraft | objMenuDraft | phase 1 on_confirm pushes carousel for adept picker |
| objSummonDraft | objMenuDraft | summon choice panels |
| objChoiceDraw | objMenuDraft | 3 drawn cards as full-screen panels |
| objTownShop | objMenuCarousel | shop list build logic stays in caller |
| objTownPicker | objMenuCarousel | items = town list |
| objEchoPicker | objMenuCarousel | items = all party djinn |
| objSummonSpellPicker | objMenuCarousel | items = filtered spells |
| objMeldPicker | objMenuCarousel | items = all player weapons |
| objPsynergyLibrary | objMenuLibrary | extended to all entity types |
| objCharTarget | objMenuGrid | on_confirm = heal/buff/trade closure |
| objBossRewardPicker | objMenuGrid | on_confirm = assign boss item to character |
| objSwapPrompt | objMenuDialog | on_confirm = apply armor swap |
| objResonatePicker | objMenuDialog | buttons = Range / Damage |
| objForcePicker | objMenuSlider | label/preview show PP cost + damage |
| objMoldPicker | objMenuSlider | label shows attack count |
| objMolochPicker | objMenuSlider | label shows pair count |
| objRerollPicker | objMenuMultiSelect | items = flat dice pool |
| objMonsterTarget | **keep** | combat enemy targeting |
| objMultiKillTarget | **keep** | combat targeting variant |
| objCharonPicker | **keep** | sequential multi-kill, unusual flow |
| objPuzzlePrompt | **keep** (for now) | complex conditional logic |

---

## Phased Implementation Order

### Phase 1 — Infrastructure
- [x] Add `global.menu_stack = []` to `InitGlobalVars`
- [x] Write `PushMenu(obj_type, config)` script
- [x] Write `PopMenu()` script
- [x] Simplify `objCancel.Mouse_7` to call `PopMenu()`

### Phase 2 — `objMenuCarousel` + simple first migrations (validation)
- [x] Create `objMenuCarousel` object (Create/Destroy/Alarm/Step/Draw GUI/Mouse_56 events)
- [x] Migrate objTownPicker (trivial: list + one confirm action)
- [x] Migrate objPsynergyDraft (vertical list, one confirm per player)
- [x] Migrate objSummonMenu

### Phase 3 — `objMenuDraft` + draft migrations
- [x] Create `objMenuDraft` object
- [x] Migrate objSummonDraft
- [x] Migrate objChoiceDraw
- [x] Migrate objDjinnDraft (on_confirm pushes second objMenuDraft for adept selection)

### Phase 4 — Core combat menus
- [x] Migrate objPsynergyMenu (with on_info → objMenuLibrary stub)
- [x] Migrate objDjinniMenu
- [x] Migrate objSummonMenu (done in Phase 2)

### Phase 5 — Special menu types
- [x] Create `objMenuGrid` — migrate objCharTarget, objBossRewardPicker
- [x] Create `objMenuDialog` — migrate objSwapPrompt, objResonatePicker
- [x] Create `objMenuSlider` — migrate objForcePicker, objMoldPicker, objMolochPicker
- [x] Create `objMenuMultiSelect` — migrate objRerollPicker (objDicePicker)

### Phase 6 — `objMenuLibrary` + remaining carousels + objItemMenu
- [x] Create `objMenuLibrary`; hook up on_info across carousels
- [x] Migrate objTownShop, objEchoPicker, objMeldPicker, objSummonSpellPicker, objAssignMenu
- [x] Migrate objItemMenu (wrapped with PushMenu/PopMenu; equip/use/give via action buttons)

### Phase 7 — Cleanup
- [x] Delete all replaced object files and .yy entries (21 objects removed)
- [x] Remove from GoldenRoguelite.yyp (already absent; confirmed clean)
- [x] Final update to DestroyAllBut() — now lists generic menu objects only
- [x] Remove instance_destroy(objPsynergyMenu/DjinniMenu/SummonMenu) no-ops from CastSpell/UnleashDjinn/CastSummon
- [x] Remove stray PopMenu() from objDjinni on_confirm
- [x] Migrate PsyLookup to use PushMenu(objMenuLibrary) instead of creating objPsynergyLibrary

---

## Key Files Modified During Migration
- `scripts/CastSpell/CastSpell.gml`
- `scripts/UnleashDjinn/UnleashDjinn.gml`
- `scripts/OnUse/OnUse.gml`
- `scripts/SelectTargets/SelectTargets.gml`
- `scripts/CreateOptions/CreateOptions.gml`
- `scripts/DestroyAllBut/DestroyAllBut.gml`
- `GoldenRoguelite.yyp`

---

## Design Notes
- `on_confirm` closures capture the packet/context at push time — no global state leakage between menus
- `PopMenu()` replaces the scattered `DestroyAllBut() + CreateOptions() + ClearOptions()` pattern in every cancel handler
- Item action submenu (Use/Equip/Discard/Give) as `objMenuDialog` mirrors original Golden Sun UX and is cleaner than bottom-row multi-button layouts
- Draft type is visually distinct: full-screen, N equal panels, no scrolling list
- `objMenuLibrary` is the universal info panel; any `on_info` handler pushes it with the relevant entry list and starting index
- Description pane content (damage preview, item stats) lives in `items[].detail` and `items[].data`
- `objQuarterMenu` / `objHalfMenu` remain as passive visual containers; carousel creates them based on `description` field
