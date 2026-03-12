if phase == 0 {
	// Confirm djinni selection, move to adept pick
	chosenDjinn = djinnPool[selected]
	phase = 1
	selected = 0
	// Auto-skip to first eligible adept
	var _minDjinn = 999
	for (var p = 0; p < array_length(global.players); p++) {
		_minDjinn = min(_minDjinn, array_length(global.players[p].djinn))
	}
	while (selected < array_length(global.players) and array_length(global.players[selected].djinn) >= _minDjinn + 2) {
		selected++
	}
	if selected >= array_length(global.players) { selected = 0 }
} else {
	// Confirm adept selection, assign djinni
	var _minDjinn = 999
	for (var p = 0; p < array_length(global.players); p++) {
		_minDjinn = min(_minDjinn, array_length(global.players[p].djinn))
	}
	if array_length(global.players[selected].djinn) < _minDjinn + 2 {
		array_push(global.players[selected].djinn, chosenDjinn)
		InjectLog(global.players[selected].name + " received " + global.djinnlist[chosenDjinn].name + "!")
		global.pause = false
		DeleteButtons()
		DestroyAllBut()
		ClearOptions()
		if (global.inTown) { ProcessTownFinds() } else { ProcessPostBattleQueue() }
		CreateDicePool()
		instance_destroy()
	}
}
