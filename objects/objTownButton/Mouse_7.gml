var _dun = global.dungeonlist[global.dungeon]
var _towns = _dun.towns

// Resolve town names to indices
var _indices = []
for (var i = 0; i < array_length(_towns); i++) {
	for (var j = 0; j < array_length(global.townlist); j++) {
		if global.townlist[j].alias == _towns[i] || global.townlist[j].name == _towns[i] {
			array_push(_indices, j)
			break
		}
	}
}

if array_length(_indices) < 1 { exit }

// Build carousel items
var _items = []
for (var i = 0; i < array_length(_indices); i++) {
	var _town = global.townlist[_indices[i]]

	var _desc = ""
	if array_contains(global.townVisited, _town.name) {
		_desc = "NOT AVAILABLE"
	} else {
		_desc = string_ucfirst(_town.name) + "\n\n"
		if _town.finds[0] != "" { _desc += "- " + string_ucfirst(_town.finds[0]) + "\n" }
		if array_length(_town.finds) > 1 { _desc += "- " + string_ucfirst(_town.finds[1]) + "\n" }
		_desc += "\n\nFor Sale:\n"
		if _town.wpn_price > 0 { _desc += "- Weapons " + string(_town.wpn_price) + "g\n" }
		if _town.arm_price > 0 { _desc += "- Armor "   + string(_town.arm_price) + "g\n" }
		if _town.itm_price > 0 { _desc += "- Items "   + string(_town.itm_price) + "g\n" }
		if _town.art_price > 0 { _desc += "- Artifacts " + string(_town.art_price) + "g\n" }
		if _town.psy_price > 0 { _desc += "- Psynergy " + string(_town.psy_price) + "g\n" }
		if _town.sum_price > 0 { _desc += "- Summons "  + string(_town.sum_price) + "g\n" }
		_desc += "\n\n" + _town.quote
	}

	array_push(_items, {
		name:   _town.name,
		sprite: -1,
		detail: array_contains(global.townVisited, _town.name) ? "(visited)" : "",
		desc:   _desc,
		data:   { town_index: _indices[i] },
	})
}

PushMenu(objMenuCarousel, {
	items:         _items,
	title:         "Choose a Town",
	description:   "half",
	confirm_label: "Enter",
	filter:        method({ items: _items }, function(i) {
		return array_contains(global.townVisited, global.townlist[items[i].data.town_index].name)
	}),
	on_confirm: function(i, item) {
		DeleteButtons()
		PopMenu()
		EnterTown(item.data.town_index)
	},
})
