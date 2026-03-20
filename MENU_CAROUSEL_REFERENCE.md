# objMenuCarousel Reference

Runtime reference for `PushMenu(objMenuCarousel, config)`.

## Where the schema comes from

`PushMenu()` does not validate or reshape the config. It passes the struct straight into the new instance as creation data.

Primary runtime sources:

- `scripts/PushMenu/PushMenu.gml`
- `objects/objMenuCarousel/Create_0.gml`
- `objects/objMenuCarousel/Step_0.gml`
- `objects/objMenuCarousel/Draw_64.gml`
- `objects/objMenuCarousel/Mouse_56.gml`

## Config struct

These are the fields `objMenuCarousel` currently reads and defaults at runtime.

```gml
{
    items:          [],
    on_confirm:     function(index, item) {},
    on_cancel:      function() { PopMenu() },
    description:    "none",
    title:          "",
    filter:         undefined,
    on_info:        undefined,
    confirm_label:  "Select",
    confirm_sprite: yes,
    read_only:      false,
    no_cancel:      false,
    side:           "left",
    draw_pane:      undefined,
    info_label:     "Info",
}
```

## Field notes

### `items`

Array of display structs. Required in practice.

### `on_confirm(index, item)`

Called when the selected item is confirmed by button, keyboard, or clicking the selected row.

Not called when:

- `read_only == true`
- `filter(index)` returns `true`

### `on_cancel`

Defaulted onto the instance, but not currently used by `objMenuCarousel` itself.

Current cancel flow goes through `objCancel` and `PopMenu()`, so setting `on_cancel` on the config does not change cancel behavior unless other code calls it manually.

### `description`

Controls the right-hand pane:

- `"none"`: no description pane
- `"quarter"`: quarter pane drawn directly in `Draw_64`
- `"half"`: full half-pane background

### `title`

Optional list header. Also slightly changes how many rows are shown above the selected entry.

### `filter(index)`

Optional predicate for disabled entries.

Important behavior:

- Return `true` to grey the row out
- Greyed rows remain selectable
- Greyed rows cannot be confirmed

### `on_info(index, item)`

If provided, shows the info button and handles `INPUT_INFO` / info-button presses.

### `confirm_label`

Text shown on the confirm button.

### `confirm_sprite`

Sprite/image passed into `objConfirm`. Defaults to `yes`.

### `read_only`

If `true`:

- no confirm button is created
- keyboard confirm does nothing
- clicking the selected row does not confirm
- cancel can still exist unless `no_cancel` is also set

### `no_cancel`

If `true`, `objCancel` is not created.

### `side`

List placement:

- `"left"`: list on left, description pane on right
- `"right"`: list on right, description pane on left

### `draw_pane(selected, item)`

Optional custom draw callback for the description pane.

If omitted, the carousel falls back to drawing `items[selected].desc` when present.

### `info_label`

Text shown on the info button.

## Item struct

These are the item fields the carousel itself reads while drawing.

```gml
{
    name:         "Display Name",
    color:        c_white,
    element:      "Mars",
    sprite:       SomeSprite,
    right_sprite: AnotherSprite,
    detail:       "10 PP",
    desc:         "Description text",
}
```

## Item field notes

### `name`

Primary row label. This is the only truly expected display field.

### `color`

Optional text color for the row. Ignored when `filter(index)` returns `true`, because filtered rows are drawn grey.

### `element`

Optional element name. The carousel tries to draw:

```gml
asset_get_index(item.element + "_Star_Clean")
```

Examples: `"Venus"`, `"Mars"`, `"Jupiter"`, `"Mercury"`.

### `sprite`

Optional left-side icon.

### `right_sprite`

Optional right-side icon drawn near the row's right edge.

### `detail`

Optional right-aligned text, often used for costs, owner names, counts, or status.

### `desc`

Optional plain-text description for the pane when `draw_pane` is not supplied.

## Common project convention: `item.data`

The carousel does not read `item.data`, but many callers include it so callbacks can keep raw IDs or indexes around.

Example:

```gml
{
    name: "Flare",
    detail: "8 PP",
    data: { spell_index: 17 },
}
```

This is a useful pattern for `on_confirm`, `on_info`, and custom `draw_pane` code.

## Minimal example

```gml
PushMenu(objMenuCarousel, {
    items: [
        { name: "Vale", desc: "A quiet starting town.", data: { town_index: 0 } },
        { name: "Vault", desc: "A bustling trading town.", data: { town_index: 1 } },
    ],
    title:         "Choose a Town",
    description:   "half",
    confirm_label: "Enter",
    on_confirm: function(i, item) {
        PopMenu()
        EnterTown(item.data.town_index)
    },
})
```

## Example with disabled rows and custom pane

```gml
PushMenu(objMenuCarousel, {
    items:         _items,
    description:   "quarter",
    confirm_label: "Cast",
    filter: function(i) {
        return !isCastable(global.psynergylist[_items[i].data.spell_index], global.players[global.turn])
    },
    draw_pane: function(sel, item) {
        draw_text_ext(820, 411, item.desc, 40, 660)
    },
    on_confirm: function(i, item) {
        CastSpell(item.data.spell_index, global.turn)
    },
    on_info: function(i, item) {
        // open a secondary info menu
    },
})
```

## Live examples in this project

- `objects/objPsynergy/Mouse_7.gml`
- `objects/objDjinni/Mouse_7.gml`
- `objects/objTownButton/Mouse_7.gml`
- `scripts/_BuildPsynergyDraftConfig/_BuildPsynergyDraftConfig.gml`
- `scripts/_PushSummonSpellMenu/_PushSummonSpellMenu.gml`
- `scripts/CastSpell/CastSpell.gml`
- `scripts/UnleashDjinn/UnleashDjinn.gml`

## Caveats

- Extra config fields are allowed by `PushMenu()`, but `objMenuCarousel` ignores anything it does not explicitly read.
- Extra item fields are also fine; they simply pass through to your callbacks.
- `on_cancel` looks like intended API surface, but as of the current runtime it is not connected to the active cancel button flow.
