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

	// Shared post-damage resolution — used by both animated and non-animated paths
	var _resolve = method({ s: _struct, m: monsters, rep: repeater, src: source }, function() {
		var _any_alive = false
		for (var j = 0; j < array_length(m); j++) {
			if m[j].monsterHealth != 0 { _any_alive = true; break }
		}
		if _any_alive {
			global.inCombat = true
			if rep > 1 {
				var _total = rep
				MakeTurnDelay(15, method({ s: s, r: rep - 1, t: _total }, function() {
					_FireRepeats(s, r, 15, t)
				}))
			} else {
				if src == "attack" { QueueOnAttack() }
				if array_length(global.attackQueue) > 0 {
					ProcessAttackQueue()
				} else {
					MakeTurnDelay(20, NextTurn)
				}
			}
		} else {
			HandleVictory()
		}
	})

	var _anims = global.pendingAnim
	global.pendingAnim = undefined
	if _anims != undefined {
		// Normalize single struct to array
		if !is_array(_anims) { _anims = [_anims] }
		// Check if any step requests staggered per-target damage
		var _stagger_dmg = false
		for (var _a = 0; _a < array_length(_anims); _a++) {
			if _anims[_a][$ "stagger_damage"] ?? false { _stagger_dmg = true; break }
		}
		// Queue animation steps
		var _first_hit = true
		var _hit_count = 0
		if _stagger_dmg {
			// Step-major: all targets get step 0, then all get step 1, etc.
			// This lets wind/flash group targets simultaneously, bursts play sequentially
			for (var _a = 0; _a < array_length(_anims); _a++) {
				for (var _t = 0; _t < array_length(targets); _t++) {
					var _anim = variable_clone(_anims[_a])
					if variable_struct_exists(_anim, "fires_hit") and _anim.fires_hit {
						_anim._stagger_target_index = _t
						_hit_count++
					}
					QueueAnim(_anim.type, _anim.element, targets[_t], _anim)
				}
			}
		} else {
			// Check if animation should only play on one target
			var _single = false
			for (var _a = 0; _a < array_length(_anims); _a++) {
				if _anims[_a][$ "single_anim"] ?? false { _single = true; break }
			}
			var _anim_target = floor((array_length(targets) - 1) / 2) // middle target gets the visual

			// Build ordered list of all alive monsters for splash steps
			var _all_monsters = []
			with (objMonster) {
				if monsterHealth > 0 { array_push(_all_monsters, id) }
			}

			// Target-major: each target gets all steps before the next target
			for (var _t = 0; _t < array_length(targets); _t++) {
				if _single and _t != _anim_target { continue }
				for (var _a = 0; _a < array_length(_anims); _a++) {
					var _anim = variable_clone(_anims[_a])
					// target_all / target_splash: queue on extra monsters beyond just this target
					var _extra_mode = _anim[$ "target_all"] ?? (_anim[$ "target_splash"] ?? false)
					if _extra_mode != false {
						if _t == 0 or (_single and _t == _anim_target) {
							// Find target's index in the all_monsters list
							var _tgt = targets[_t]
							var _tgt_idx = -1
							for (var _m = 0; _m < array_length(_all_monsters); _m++) {
								if _all_monsters[_m] == _tgt { _tgt_idx = _m; break }
							}
							for (var _m = 0; _m < array_length(_all_monsters); _m++) {
								// target_splash: only target and immediate neighbors
								if _extra_mode == "splash" and abs(_m - _tgt_idx) > 1 { continue }
								var _ma = variable_clone(_anim)
								_ma.fires_hit = false
								QueueAnim(_ma.type, _ma.element, _all_monsters[_m], _ma)
							}
						}
						continue
					}
					if variable_struct_exists(_anim, "fires_hit") and _anim.fires_hit {
						if !_first_hit { _anim.fires_hit = false }
						_first_hit = false
					}
					QueueAnim(_anim.type, _anim.element, targets[_t], _anim)
				}
			}
		}
		if _stagger_dmg {
			// Each fires_hit triggers DoDamage for just that target
			PlayAnimation(method({ s: _struct, tgts: targets }, function() {
				var _anim_inst = instance_find(objSpellAnimation, 0)
				var _copy = variable_clone(s)
				// Barrage mode: meteor stores hit target directly
				if instance_exists(_anim_inst) and variable_instance_exists(_anim_inst, "_barrage_hit_target")
					and instance_exists(_anim_inst._barrage_hit_target) {
					_copy.targets = [_anim_inst._barrage_hit_target]
				} else {
					// Normal stagger: look up target index from queue step
					var _ti = 0
					if instance_exists(_anim_inst) {
						var _step = _anim_inst._queue[_anim_inst._qi]
						_ti = _step[$ "_stagger_target_index"] ?? 0
					}
					_copy.targets = [tgts[_ti]]
				}
				DoDamage(_copy)
			}), _resolve)
		} else {
			PlayAnimation(method({ s: _struct }, function() { DoDamage(s) }), _resolve)
		}
	} else {
		DoDamage(_struct)
		_resolve()
	}

}