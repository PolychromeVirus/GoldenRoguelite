/// @func ProcessAttackQueue()
/// @desc Shift the next entry from global.attackQueue and call SelectTargets with it.
///       If the queue is empty, proceed to next turn.
function ProcessAttackQueue() {
	if array_length(global.attackQueue) == 0 {
		// Queue empty — proceed to next turn
		global.pause = false
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
		return
	}
	
	var a = variable_clone(global.attackQueue[0])
	
	array_delete(global.attackQueue, 0, 1)

	//SelectTargets(entry.num, entry.target, entry.dam, entry.type, entry.statuses)
	SelectTargets(a)
}
