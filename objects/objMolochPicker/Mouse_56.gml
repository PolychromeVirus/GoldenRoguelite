if instance_position(mouse_x, mouse_y, objConfirm) {
	var _data = { number: selected }
	if source = "summon"{
		AddPassive("nullify_move", -1, asset_get_index("Moloch"), "Moloch", _data, caster_id)
		InjectLog("Moloch nullifies enemy move #" + string(selected) + "!")
	}
	if source = "djinni"{
		AddPassive("reroll_move", 3, Venus875, "Petra", _data, caster_id)
		InjectLog("Petra restricts the enemies options!")
	}

	DeleteButtons()
	global.pause = false
	NextTurn()
	instance_destroy()
}
