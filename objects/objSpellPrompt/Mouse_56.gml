if instance_exists(objConfirm) && instance_position(mouse_x, mouse_y, objConfirm) != noone {
	// Deduct PP
	global.players[caster_index].pp -= pp_cost
	InjectLog(global.players[caster_index].name + " casts " + spell_name + "!")

	var _cb = on_confirm
	ClearOptions()
	global.pause = false
	_cb()
	instance_destroy()
}

if instance_exists(objButton2) && instance_position(mouse_x, mouse_y, objButton2) != noone {
	if objCancel.clickable {
		var _cb = on_decline
		ClearOptions()
		global.pause = false
		_cb()
		instance_destroy()
	}
}
