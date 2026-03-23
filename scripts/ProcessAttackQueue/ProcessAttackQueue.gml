/// @func ProcessAttackQueue()
/// @desc Shift the next entry from global.attackQueue and call SelectTargets with it.
///       If the queue is empty, proceed to next turn.
function ProcessAttackQueue() {
	if array_length(global.attackQueue) == 0 {
		// Queue empty — proceed to next turn
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30, on_complete: NextTurn})
		return
	}
	
	var a = variable_clone(global.attackQueue[0])
	array_delete(global.attackQueue, 0, 1)

	// Callback entry — run function instead of SelectTargets
	if variable_struct_exists(a, "callback") {
		a.callback()
		return
	}

	// Restore per-attack animation if stored on the struct
	if variable_struct_exists(a, "anim") {
		global.pendingAnim = a.anim
		variable_struct_remove(a, "anim")
	}

	a.committed = true   // cancel on this targeter ends the turn, not returns to menu
	SelectTargets(a)
}
