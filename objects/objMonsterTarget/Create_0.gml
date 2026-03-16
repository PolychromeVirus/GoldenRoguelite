//spells = []

//for (var i = 0; i<array_length(global.players[global.turn].spells); i++){
//	for (var j = 0; j<array_length(global.psynergylist); j++){
//		if global.psynergylist[j].name == global.players[global.turn].spells[i]{
//			array_push(spells, global.psynergylist[j])
//		}
//	}
//}


// Cancel any pending ButtonManager alarm so a queued _build_buttons() doesn't fire
with (objButtonManager) { alarm[0] = -1 }

// Hide menu stack instances (and their panes) so they don't render behind the targeter
for (var _i = 0; _i < array_length(global.menu_stack); _i++) {
    var _inst = global.menu_stack[_i]
    if instance_exists(_inst) {
        _inst.visible = false
        if variable_instance_exists(_inst, "pane") and instance_exists(_inst.pane) {
            _inst.pane.visible = false
        }
    }
}
DeleteButtons()

var button1 = 36
var button2 = 64

using_kbd = false
_prev_mx  = device_mouse_x_to_gui(0)
_prev_my  = device_mouse_y_to_gui(0)
monsters = []
var count = instance_number(objMonster)
for (var i = 0; i < count; i++) {
	var inst = instance_find(objMonster, i)
	array_push(monsters, inst)
}

instance_create_depth(button1,124,0,objConfirm)
instance_create_depth(button2,124,0,objCancel)

alarm_set(0,1)

function logic(){
	confirmed = true   // tell Destroy_0 not to call CreateOptions
	while array_length(global.menu_stack) > 0 { PopMenu() }

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
				instance_create_depth(0, 0, 0, TurnDelay, { wait: 30, on_complete: NextTurn })
			}
		}
		exit
	}

	// Victory — clear remaining queue
	HandleVictory()
	instance_destroy()

}