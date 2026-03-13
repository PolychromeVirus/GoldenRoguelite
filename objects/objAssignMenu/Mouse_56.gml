if instance_position(mouse_x,mouse_y,objConfirm){
	var _struct = variable_clone(global.AggressionSchema)
	_struct.num = 1
	_struct.target = target
	if (target == "ally") {
		_struct.healing = dice[selected]
	} else {
		_struct.dam = dice[selected]
	}
	_struct.dmgtype = string_lower(element)
	if num > 1{
		array_push(global.attackQueue,variable_clone(_struct) )
		if !repeater {array_delete(dice,selected,1)}
		num--
	}else{
		array_push(global.attackQueue,variable_clone(_struct))
		ClearOptions()
		ProcessAttackQueue()
		instance_destroy()
	}

}