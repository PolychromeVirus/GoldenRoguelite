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
	
	if splash != -1{instance_create_depth(0,0,500,objSummonSplash,{spr: splash})}
	_struct.troop = monsters

	// Shared post-damage resolution — used by both animated and non-animated paths
	var _resolve = method({ s: _struct, m: monsters, rep: repeater, src: source, li: _struct[$ "loop_index"] ?? 0 }, function() {
		var _any_alive = false
		for (var j = 0; j < array_length(m); j++) {
			if m[j].monsterHealth != 0 { _any_alive = true; break }
		}
		if _any_alive {
			global.inCombat = true
			if rep > 0 {
				var _total = rep + 1
				MakeTurnDelay(15, method({ s: s, r: rep, t: _total, li: li + 1 }, function() {
					_FireRepeats(s, r, 15, t, li)
				}))
			} else {
				if src == "attack" { QueueOnAttack() }
				if array_length(global.attackQueue) > 0 {
					ProcessAttackQueue()
				} else {
					MakeTurnDelay(s[$ "post_delay"] ?? 20, NextTurn)
				}
			}
		} else {
			 //HandleVictory()
			 MakeTurnDelay(30, NextTurn)
		}
	})

	// --- Daedalus: build cascade pillar layers dynamically ---
	if variable_global_exists("daedalusAnim") and global.daedalusAnim {
		global.daedalusAnim = false
		global.daedalusCascade = false  // disable old DoDamage cascade — handled per-layer now
		var _base_outer = 64
		var _base_core  = 40
		var _base_dam = _struct.dam
		var _dam_col = ElementColor(_struct.element)
		var _max_dist = 0
		for (var _m = 0; _m < array_length(monsters); _m++) {
			var _d = abs(_m - selected)
			if _d > _max_dist { _max_dist = _d }
		}
		var _dae_layers = []
		for (var _dist = 0; _dist <= _max_dist; _dist++) {
			var _scale = power(0.5, _dist)
			var _ow = max(4, round(_base_outer * _scale))
			var _cw = max(2, round(_base_core * _scale))
			var _cascade_dam = (_dist == 0) ? _base_dam : max(1, ceil(_base_dam * _scale))
			var _group_targets = []
			for (var _m = 0; _m < array_length(monsters); _m++) {
				if abs(_m - selected) != _dist { continue }
				if monsters[_m].monsterHealth <= 0 { continue }
				array_push(_group_targets, monsters[_m])
			}
			if array_length(_group_targets) > 0 {
				var _dae_hit = method({ dam: _cascade_dam, col: _dam_col }, function(_mon) {
					if !instance_exists(_mon) { return }
					if _mon.monsterHealth <= 0 { return }
					_mon.monsterHealth -= dam
					_mon.flash_timer = FLASH_DURATION; _mon.damage_timer = DAMAGE_DURATION; _mon.flash_color = col
					InjectLog(_mon.name + " takes " + string(dam) + " cascade damage!")
					if _mon.monsterHealth <= 0 {
						_mon.monsterHealth = 0
						global.gold += 1
					}
				})
				array_push(_dae_layers, {
					type: "pillar", element: "mars", mode: "simultaneous",
					targets: _group_targets, delay: _dist * 35,
					fires_hit: false, hit_delay: 6, on_hit: _dae_hit, sfx: HugeExplosion,
					outer_w: _ow, core_w: _cw,
					hold: 30, fade: 20, linger: 10,
					shake: (_dist == 0) ? 5 : 0, shake_duration: 15
				})
			}
		}
		_struct.anim = _dae_layers
	}

	// --- Animation system: read anim layers from struct ---
	var _anim_layers = _struct[$ "anim"]

	if _anim_layers != undefined {
		// Normalize: single struct → array
		if !is_array(_anim_layers) { _anim_layers = [_anim_layers] }
		// Filter layers by anim_loop — default to loop 0 if any layer uses anim_loop
		var _loop_idx = _struct[$ "loop_index"] ?? 0
		var _any_looped = false
		for (var _fi = 0; _fi < array_length(_anim_layers); _fi++) {
			if !is_undefined(_anim_layers[_fi][$ "anim_loop"]) { _any_looped = true; break }
		}
		if _any_looped {
			var _filtered = []
			for (var _fi = 0; _fi < array_length(_anim_layers); _fi++) {
				var _fl = _anim_layers[_fi][$ "anim_loop"]
				if is_undefined(_fl) or _fl == _loop_idx { array_push(_filtered, _anim_layers[_fi]) }
			}
			_anim_layers = _filtered
		}
		// Translate legacy flags to new mode system
		for (var _li = 0; _li < array_length(_anim_layers); _li++) {
			var _layer = _anim_layers[_li]
			// Legacy stagger_damage → mode: "stagger"
			if is_undefined(_layer[$ "mode"]) {
				if _layer[$ "stagger_damage"] ?? false {
					_layer.mode = "stagger"
					_layer.stagger_delay = _layer[$ "stagger"] ?? 15
				}
				// Legacy single_anim → mode: "shared"
				else if _layer[$ "single_anim"] ?? false {
					_layer.mode = "shared"
				}
			}
			// Legacy target_all → set targets to all alive monsters
			if _layer[$ "target_all"] ?? false {
				var _all_alive = []
				with (objMonster) { if monsterHealth > 0 { array_push(_all_alive, id) } }
				_layer.targets = _all_alive
				_layer.mode = _layer[$ "mode"] ?? "simultaneous"
			}
			// Legacy target_splash → targets = selected + neighbors
			else if (_layer[$ "target_splash"] ?? false) != false {
				var _all_alive = []
				with (objMonster) { if monsterHealth > 0 { array_push(_all_alive, id) } }
				var _sel_idx = -1
				for (var _m = 0; _m < array_length(_all_alive); _m++) {
					if _all_alive[_m] == targets[0] { _sel_idx = _m; break }
				}
				var _splash_tgts = []
				for (var _m = 0; _m < array_length(_all_alive); _m++) {
					if abs(_m - _sel_idx) <= 1 { array_push(_splash_tgts, _all_alive[_m]) }
				}
				_layer.targets = _splash_tgts
				_layer.mode = _layer[$ "mode"] ?? "simultaneous"
			}
			// Set default targets on layers that don't specify them
			else if is_undefined(_layer[$ "targets"]) and is_undefined(_layer[$ "target"]) {
				_layer.targets = targets
			}
		}
		// Log cast name and play cast sound with pause before animation
		var _cast_name = _struct[$ "cast_name"]
		if !is_undefined(_cast_name) {
			InjectLog(_cast_name)
		}
		var _cast_sfx = undefined
		switch _struct.source {
			case "psynergy": _cast_sfx = asset_get_index("SpellCast");  break
			case "summon":   _cast_sfx = asset_get_index("SpellCast"); break
			case "djinni":   _cast_sfx = asset_get_index("DjinnCast");  break
		}
		if !is_undefined(_cast_sfx) and _cast_sfx >= 0 {
			audio_stop_sound(_cast_sfx)
			audio_play_sound(_cast_sfx, 0, 0)
		}
		// Set targets on the packet for DoDamage
		_struct.targets = targets
		// Pause for cast sound before starting animation
		var _cast_delay = 85
		if variable_struct_exists(_struct,"cast_delay"){ _cast_delay = _struct.cast_delay }
		instance_create_depth(0, 0, 0, TurnDelay, {
			wait: _cast_delay,
			on_complete: method({ layers: _anim_layers, pkt: _struct, resolve: _resolve }, function() {
				AnimPlay(layers, pkt, resolve)
			})
		})
	} else {
		DoDamage(_struct)
		_resolve()
	}

}