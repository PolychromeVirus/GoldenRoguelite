function RollArmorBreaks() {
	for (var i = 0; i < array_length(global.players); i++) {
		var _p = global.players[i]
		for (var j = 0; j < array_length(_p.armor); j++) {
			var _arm = global.itemcardlist[_p.armor[j]]
			if (_arm.break_die > 0 && !_p.broken_armor[j]) {
				var _roll = irandom(_arm.break_die - 1)
				if (_roll == 0) {
					_p.broken_armor[j] = true
					InjectLog(_p.name + "'s " + _arm.name + " broke!")
				}
			}
		}
	}
}
