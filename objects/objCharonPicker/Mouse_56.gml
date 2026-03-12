if instance_position(mouse_x, mouse_y, objConfirm) {
	var pairs = selected

	// Spend pairs * 2 random ready djinn → recovery
	var spent = 0
	var needed = pairs * 2
	for (var p = 0; p < array_length(global.players); p++) {
		var pl = global.players[p]
		if !variable_struct_exists(pl, "djinn") { continue }
		for (var d = 0; d < array_length(pl.djinn); d++) {
			if spent >= needed { break }
			var dj = global.djinnlist[pl.djinn[d]]
			if (dj.ready or dj.spent) {
				dj.ready = false
				dj.spent = false
				global.justSummoned = true
				spent++
			}
		}
		if spent >= needed { break }
	}

	InjectLog("Charon consumes " + string(spent) + " djinn!")

	// Multi-select instant kill via objMultiKillTarget
	DeleteButtons()
	global.pause = false
	instance_create_depth(0, 0, 0, objMultiKillTarget, { kills_remaining: pairs, splash_spr: Charon1110 })
	instance_destroy()
}
