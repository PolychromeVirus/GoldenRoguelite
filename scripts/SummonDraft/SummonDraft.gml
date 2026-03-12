/// SummonDraft()
/// Picks 2 random summons not already known, spawns the draft UI.
function SummonDraft() {
	// Collect summon indices not yet in knownSummons
	var _available = []
	for (var i = 0; i < array_length(global.summonlist); i++) {
		if !array_contains(global.knownSummons, i) {
			array_push(_available, i)
		}
	}

	// Shuffle
	_available = array_shuffle(_available)

	// Take up to 2
	var _count = min(array_length(_available), 2)
	global.summonDraftPool = []
	for (var i = 0; i < _count; i++) {
		array_push(global.summonDraftPool, _available[i])
	}

	if _count > 0 {
		global.pause = true
		DestroyAllBut()
		DeleteButtons()
		ClearOptions()
		instance_create_depth(0, 0, 100, objSummonDraft)
	} else {
		// All summons already known, skip
		ProcessPostBattleQueue()
	}
}
