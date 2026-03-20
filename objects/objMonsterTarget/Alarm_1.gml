// Scatter: re-pick a random target for each repeat hit
if variable_struct_exists(_repeat_struct, "unleash") and variable_struct_exists(_repeat_struct.unleash, "scatter") and _repeat_struct.unleash.scatter {
    var _len = array_length(monsters)
    if variable_struct_exists(_repeat_struct.unleash, "scatter_any") and _repeat_struct.unleash.scatter_any {
        _repeat_struct.targets = [monsters[irandom(_len - 1)]]
    } else {
        var _candidates = []
        if selected > 0 { array_push(_candidates, selected - 1) }
        array_push(_candidates, selected)
        if selected < _len - 1 { array_push(_candidates, selected + 1) }
        _repeat_struct.targets = [monsters[_candidates[irandom(array_length(_candidates) - 1)]]]
    }
}

DoDamage(_repeat_struct)

// Check if any monsters survive
var _any_alive = false
for (var j = 0; j < array_length(monsters); j++) {
	if monsters[j].monsterHealth != 0 {
		_any_alive = true
		break
	}
}

if !_any_alive {
	MakeTurnDelay(120,HandleVictory)
	PopMenu()
	exit
}

if repeater > 1 {
	repeater--
	alarm[1] = 3
} else {
	// Done repeating — check for onAttack follow-ups
	if (source == "attack") { QueueOnAttack() }
	PopMenu()
	if array_length(global.attackQueue) > 0 {
		ProcessAttackQueue()
	} else {
		MakeTurnDelay(30, NextTurn)
	}
}
