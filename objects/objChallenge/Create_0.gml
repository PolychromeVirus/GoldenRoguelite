var _ch = global.floorChallenges[challenge_index]

// Set sprite based on challenge type
if (_ch.type == "combat" or _ch.type == "boss") {
	sprite_index = Battle
} else {
	sprite_index = Psynergy
}

// Hovertext shows troop size, or Mini-Boss for boss encounters
if (_ch.type == "combat") {
	var _has_boss = false
	for (var i = 0; i < array_length(_ch.troop); i++) {
		for (var j = 0; j < array_length(global.monsterlist); j++) {
			if (global.monsterlist[j].name == _ch.troop[i] && global.monsterlist[j].boss) {
				_has_boss = true
				break
			}
		}
		if (_has_boss) { break }
	}
	if (_has_boss) {
		hovertext = "Mini-Boss"
	} else {
		hovertext = string(array_length(_ch.troop)) + " enemies"
	}
} else if (_ch.type == "puzzle") {
	var _puz = global.puzzlelist[_ch.puzzle_index]
	hovertext = _puz.name
	// Tint traps red/orange if not yet disarmed
	if (_puz.trap && !_ch.completed) {
		image_blend = make_colour_rgb(255, 120, 60)
	}
} else if (_ch.type == "boss") {
	hovertext = "Boss"
} else {
	hovertext = _ch.type
}

if (_ch.completed) {
	image_blend = c_grey
	image_alpha = 0.4
}

alarm_set(0, 30)
