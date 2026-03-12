function logic(){

	var _struct = variable_clone(global.AggressionSchema)
	global.lastselected = selected
	global.textdisplay = ""
    if array_length(monsters) == 0 { exit }

    // Deduct deferred PP cost (from CastSpell)
    if variable_global_exists("pendingPPCost") and global.pendingPPCost > 0 {
        global.players[global.pendingPPCaster].pp -= global.pendingPPCost
        global.pendingPPCost = 0
    }

    // Build target list from selected outward
    var _indices = GetTargetIndices(selected, num, array_length(monsters))
    targets = []
    for (var _t = 0; _t < array_length(_indices); _t++) {
        array_push(targets, monsters[_indices[_t]])
    }
	var _names = variable_instance_get_names(id)
	
	for (var i=0;i<array_length(_names);i++){
		variable_struct_set(_struct,_names[i],variable_instance_get(id,_names[i]))
	}
	
	if splash != -1{instance_create_depth(0,0,0,objSummonSplash,{spr: splash})}
	_struct.troop = monsters
	DoDamage(_struct)

	// Check if any monsters survive
	var _any_alive = false
	for(var j=0;j<array_length(monsters);j++){
		if monsters[j].monsterHealth != 0{
			_any_alive = true
			break
		}
	}


	if _any_alive{
		global.inCombat = true
		if repeater > 1 {
			_repeat_struct = _struct
			repeater--
			DeleteButtons()
			alarm[1] = 3
		} else {
			// Check for onAttack follow-ups (ring effects)
			if (source == "attack") { QueueOnAttack() }
			instance_destroy()
			// If attack queue has more entries, process next instead of NextTurn
			if array_length(global.attackQueue) > 0 {
				ProcessAttackQueue()
			}
			else
			{
				global.pause = false
				instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
			}
		}
		exit
	}

	// Victory — clear remaining queue
	HandleVictory()
	instance_destroy()

}


if instance_position(mouse_x, mouse_y, objConfirm) and clickable {
	
	logic()

}

if instance_position(mouse_x, mouse_y, objMonster) and clickable {
	
	logic()

}