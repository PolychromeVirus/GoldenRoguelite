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

	// Queue one instant-kill targeter per pair
	for (var _k = 0; _k < pairs; _k++) {
		var _s = variable_clone(global.AggressionSchema)
		_s.dam     = 9999
		_s.target  = "enemy"
		_s.num     = 1
		_s.source  = "summon"
		_s.dmgtype = "none"
		_s.splash  = (_k == 0) ? Charon1110 : -1
		array_push(global.attackQueue, _s)
	}
	DeleteButtons()
	ProcessAttackQueue()
	instance_destroy()
}
