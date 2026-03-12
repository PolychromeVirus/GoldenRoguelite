if instance_exists(objConfirm) and instance_position(mouse_x, mouse_y, objConfirm) {
	// Calculate damage from top N elemental pips
	var _dam = 0
	for (var _i = 0; _i < selected; _i++) {
		_dam += elemPips[_i]
	}

	// Set PP cost for this cast
	var _pp = selected * costPer
	global.pendingPPCost = _pp

	// Build aggression packet
	var _struct = variable_clone(global.AggressionSchema)
	_struct.source = "psynergy"
	_struct.dam = _dam
	_struct.num = 1
	_struct.dmgtype = "none"
	_struct.target = "enemy"
	
	DeleteButtons()
	global.pause = false
	SelectTargets(_struct)
	instance_destroy()
}

if instance_exists(objCancel) and instance_position(mouse_x, mouse_y, objCancel) {
	if objCancel.clickable {
		global.pendingPPCost = 0
		global.textdisplay = ""
		DestroyAllBut()
		CreateOptions()
		ClearOptions()
	}
}
