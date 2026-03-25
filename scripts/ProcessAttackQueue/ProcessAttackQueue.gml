/// @func ProcessAttackQueue()
/// @desc Shift the next entry from global.attackQueue and call SelectTargets with it.
///       If the queue is empty, proceed to next turn.
function ProcessAttackQueue() {
	if array_length(global.attackQueue) == 0 {
		// Queue empty — proceed to next turn
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30, on_complete: NextTurn})
		return
	}

	if !variable_global_exists("_attack_queue_index") { global._attack_queue_index = 0 }

	var a = variable_clone(global.attackQueue[0])
	array_delete(global.attackQueue, 0, 1)
	a.loop_index = global._attack_queue_index
	global._attack_queue_index++
	if array_length(global.attackQueue) == 0 { global._attack_queue_index = 0 }

	// Callback entry — run function instead of SelectTargets
	if variable_struct_exists(a, "callback") {
		a.callback()
		return
	}

	// Per-attack animation: stays on the struct as .anim
	// (AnimPlay reads it from the packet directly)

	a.committed = true   // cancel on this targeter ends the turn, not returns to menu
	SelectTargets(a)
}
