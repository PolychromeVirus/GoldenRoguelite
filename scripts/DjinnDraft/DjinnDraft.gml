/// DjinnDraft()
/// Picks 3 random djinn not already owned by any adept, spawns the draft UI.
function DjinnDraft() {
	// Collect all djinn IDs not currently owned by any player
	var _available = []
	for (var i = 0; i < array_length(global.djinnlist); i++) {
		var _owned = false
		for (var p = 0; p < array_length(global.players); p++) {
			for (var d = 0; d < array_length(global.players[p].djinn); d++) {
				if global.players[p].djinn[d] == i { _owned = true; break }
			}
			if _owned { break }
		}
		if !_owned and real(global.djinnlist[i].chapter) <= global.dungeon + 1{ array_push(_available, i) }
	}

	// Shuffle (Fisher-Yates)
	var _len = array_length(_available)
	for (var i = _len - 1; i > 0; i--) {
		var j = irandom(i)
		var _tmp = _available[i]
		_available[i] = _available[j]
		_available[j] = _tmp
	}

	// Take up to 3
	var _count = min(_len, 3)
	global.djinnDraftPool = []
	for (var i = 0; i < _count; i++) {
		array_push(global.djinnDraftPool, _available[i])
	}

	if _count > 0 {
		global.pause = true
		DestroyAllBut()
		DeleteButtons()
		ClearOptions()
		instance_create_depth(0, 0, 100, objDjinnDraft)
	}
}
