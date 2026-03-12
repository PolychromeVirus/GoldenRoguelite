// Right arrow
if phase == 0 {
	if selected == array_length(djinnPool) - 1 { selected = 0 }
	else { selected += 1 }
} else {
	var _minDjinn = 999
	for (var p = 0; p < array_length(global.players); p++) {
		_minDjinn = min(_minDjinn, array_length(global.players[p].djinn))
	}
	// Move right, skip ineligible
	var _start = selected
	do {
		if selected == array_length(global.players) - 1 { selected = 0 }
		else { selected += 1 }
	} until (array_length(global.players[selected].djinn) < _minDjinn + 2 or selected == _start)
}
