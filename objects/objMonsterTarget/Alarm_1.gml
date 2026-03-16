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
	HandleVictory()
	instance_destroy()
	exit
}

if repeater > 1 {
	repeater--
	alarm[1] = 3
} else {
	// Done repeating — check for onAttack follow-ups
	if (source == "attack") { QueueOnAttack() }
	instance_destroy()
	if array_length(global.attackQueue) > 0 {
		ProcessAttackQueue()
	} else {
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
	}
}
