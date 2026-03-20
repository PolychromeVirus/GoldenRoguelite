if instance_position(mouse_x,mouse_y,objConfirm){
	global.players[selector] = variable_clone(global.characterlist[selected])
	var _p = global.players[selector]
	if array_length(_p.starters) > 0 {
		array_push(_p.spells, _p.starters[starter_selected])
	}
	PopMenu()
}