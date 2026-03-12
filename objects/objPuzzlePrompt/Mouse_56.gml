// Confirm — disarm the puzzle
if (!no_caster && instance_exists(objConfirm) && instance_position(mouse_x, mouse_y, objConfirm) != noone) {
	var _ch = global.floorChallenges[challenge_index]

	// Deduct PP
	if (is_overload) {
		global.players[caster].pp -= 8
		InjectLog(global.players[caster].name + " absorbs the " + overload_element + " overload!")
	} else {
		var _psyID = FindPsyID(spell_name, 0)
		var _cost = global.psynergylist[_psyID].cost
		global.players[caster].pp -= _cost
		InjectLog(global.players[caster].name + " casts " + spell_name + "!")
	}

	// Mark completed
	_ch.completed = true

	// If trap, remove floor effect
	if (puzzle.trap) {
		for (var _i = array_length(global.floorEffects) - 1; _i >= 0; _i--) {
			if (global.floorEffects[_i].puzzle_index == puzzle_index) {
				array_delete(global.floorEffects, _i, 1)
			}
		}
		InjectLog("Trap disarmed!")
	} else {
		// Apply reward
		ApplyPuzzleReward(puzzle)
	}

	ClearOptions()
	global.pause = false
	CreateOptions()
	instance_destroy()
}

// Cancel — close without solving
if (instance_exists(objCancel) && instance_position(mouse_x, mouse_y, objCancel) != noone) {
	if (objCancel.clickable) {
		ClearOptions()
		global.pause = false
		CreateOptions()
		instance_destroy()
	}
}