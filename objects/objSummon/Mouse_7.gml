if instance_exists(objStatDisplay) { objStatDisplay.viewPlayer = global.turn }

// Don't push if a menu is already open
if array_length(global.menu_stack) > 0 { exit }

// Build items from known summons
var _items = []
for (var i = 0; i < array_length(global.knownSummons); i++) {
	var _id     = global.knownSummons[i]
	var _summon = global.summonlist[_id]
	var _spr    = asset_get_index(_summon.alias)

	// Build djinn cost string
	var _cost = ""
	if _summon.venus    > 0 { _cost += string(_summon.venus)    + "V " }
	if _summon.mars     > 0 { _cost += string(_summon.mars)     + "Ma " }
	if _summon.jupiter  > 0 { _cost += string(_summon.jupiter)  + "J " }
	if _summon.mercury  > 0 { _cost += string(_summon.mercury)  + "Me " }
	_cost = string_trim(_cost)

	var _desc = _summon.text
	if string_length(_desc) > 170 { _desc = string_delete(_desc, 170, string_length(_desc) - 169) + "..." }

	array_push(_items, {
		name:   _summon.name,
		sprite: (_spr != -1) ? _spr : -1,
		detail: _cost,
		desc:   _desc,
		data:   { summon_id: _id },
	})
}

PushMenu(objMenuCarousel, {
	items:         _items,
	description:   "quarter",
	confirm_label: "Summon",
	filter:        method({ _items: _items }, function(i) {
		return !isSummonable(global.summonlist[_items[i].data.summon_id])
	}),
	on_confirm: function(i, item) {
		DeleteButtons()
		PopMenu()
		CastSummon(item.data.summon_id, global.turn)
	},
})
