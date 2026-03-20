//spells = []

//for (var i = 0; i<array_length(global.players[global.turn].spells); i++){
//	for (var j = 0; j<array_length(global.psynergylist); j++){
//		if global.psynergylist[j].name == global.players[global.turn].spells[i]{
//			array_push(spells, global.psynergylist[j])
//		}
//	}
//}




// Hide menu stack instances (and their panes) so they don't render behind the targeter
//for (var _i = 0; _i < array_length(global.menu_stack); _i++) {
//    var _inst = global.menu_stack[_i]
//    if instance_exists(_inst) {
//        _inst.visible = false
//        if variable_instance_exists(_inst, "pane") and instance_exists(_inst.pane) {
//            _inst.pane.visible = false
//        }
//    }
//}

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

alarm_set(0,1)

_build_buttons = method(id, function() {
    var sprite = {image: Fight, text: "Select"}
    instance_create_depth(BUTTON1, BOTTOMROW, 0, objConfirm, sprite)
    instance_create_depth(BUTTON2, BOTTOMROW, 0, objCancel)
})

function logic(){
	PopAll()
	confirmed = true   // tell Destroy_0 not to call CreateOptions
	//while array_length(global.menu_stack) > 0 { PopMenu() }

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

    // Scatter: pick a random target for the first hit (subsequent hits re-pick in Alarm_1)
    if variable_struct_exists(unleash, "scatter") and unleash.scatter {
        var _len = array_length(monsters)
        if variable_struct_exists(unleash, "scatter_any") and unleash.scatter_any {
            targets = [monsters[irandom(_len - 1)]]
        } else {
            var _candidates = []
            if selected > 0 { array_push(_candidates, selected - 1) }
            array_push(_candidates, selected)
            if selected < _len - 1 { array_push(_candidates, selected + 1) }
            targets = [monsters[_candidates[irandom(array_length(_candidates) - 1)]]]
        }
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
			var _total = repeater
			MakeTurnDelay(15, method({s: _struct, r: repeater - 1, t: _total}, function() {
				_FireRepeats(s, r, 15, t)
			}))
		} else {
			// Check for onAttack follow-ups (ring effects)
			if (source == "attack") { QueueOnAttack() }
			if array_length(global.attackQueue) > 0 {
				ProcessAttackQueue()
			} else {
				instance_create_depth(0, 0, 0, TurnDelay, { wait: 60, on_complete: NextTurn })
			}
		}
		exit
	}

	// Victory — clear remaining queue
	HandleVictory()
	instance_destroy()

}