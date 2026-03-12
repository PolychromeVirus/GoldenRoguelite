var _dun = global.dungeonlist[global.dungeon]
var _towns = _dun.towns

// Resolve town names to indices
var _indices = []
for (var i = 0; i < array_length(_towns); i++) {
	for (var j = 0; j < array_length(global.townlist); j++) {
		if (global.townlist[j].alias == _towns[i] || global.townlist[j].name == _towns[i]) {
			array_push(_indices, j)
			break
		}
	}
}

if (array_length(_indices) > 0) {
	DeleteButtons()
	instance_create_depth(0, 0, 0, objTownPicker, { town_indices: _indices })
}
