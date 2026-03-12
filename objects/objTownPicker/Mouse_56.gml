if (instance_position(mouse_x, mouse_y, objConfirm)) {
	var _idx = town_indices[selected]
	var _town = global.townlist[_idx]
	if (!array_contains(global.townVisited, _town.name)) {
		DeleteButtons()
		instance_destroy()
		EnterTown(_idx)
	}
}
