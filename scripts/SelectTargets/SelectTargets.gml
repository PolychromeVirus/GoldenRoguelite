/// @func AnimColor(element_str)
/// @desc Saturated element colours for particle animations.
function AnimColor(element_str) {
	switch string_lower(element_str) {
		case "venus":   return #f0c000   // warm gold
		case "mars":    return #ff3300   // hot red-orange
		case "jupiter": return #cc44ff   // vivid purple
		case "mercury": return #00aaee   // cyan-blue
		case "melee":   return c_white
		default:        return make_color_rgb(180, 180, 180)  // neutral gray
	}
}

/// @func ElementColor(element_str)
/// @desc Return the global constant containing a given element's colour. White for normal/damage. (lowercase)
function ElementColor(element_str) {
	switch string_lower(element_str) {
		case "venus":   return global.c_venus
		case "mars":    return global.c_mars
		case "jupiter": return global.c_jupiter
		case "mercury": return global.c_mercury
		case "melee":   return c_white
		default:        return c_white
	}
}

function SelectTargets(struct){
	//passes through aggression struct




	struct.caster = global.players[global.turn]
	struct.dmgtype = string_lower(struct.dmgtype)
	
	if struct.caster.name == "Ivan" or struct.caster.name == "Karis"{
			StructMerge(struct.statuses,{locked: true}, false)
		}
	// Range 12 = target all enemies, skip the targeter
	if struct.num >= 12 and struct.target == "enemy" {
		var _monsters = []
		var _count = instance_number(objMonster)
		for (var _i = 0; _i < _count; _i++) {
			array_push(_monsters, instance_find(objMonster, _i))
		}
		struct.targets = _monsters
		// Deduct deferred PP cost (from CastSpell)
		if variable_global_exists("pendingPPCost") and global.pendingPPCost > 0 {
			global.players[global.pendingPPCaster].pp -= global.pendingPPCost
			global.pendingPPCost = 0
		}
		var _cast_delay = 85
		var _text = ""
		if variable_struct_exists(struct,"cast_name"){_text = struct.cast_name}
		if variable_struct_exists(struct,"cast_delay"){ _cast_delay = struct.cast_delay }
		PopAll()
		InjectLog(_text)
		MakeTurnDelay(_cast_delay, method({ pkt: variable_clone(struct)}, function(){ApplyDamageToTargets(pkt)}))  
		return
	}
	if struct.num >= 4 and struct.target == "ally"{
		if struct.healing > 0 and (struct.caster.name == "Mia" or struct.caster.name == "Rief"){
			struct.healing += 1
		}
		for (var j = 0; j < array_length(global.players); ++j) {
			var _party_heal = struct.healing
			if (global.players[j].halfheal and _party_heal > 0) { _party_heal = floor(_party_heal / 2) }
			if _party_heal > 0 and (global.players[j].hp > 0 or struct.dmgtype == "mercury"){global.players[j].hp = min(global.players[j].hp + _party_heal, global.players[j].hpmax)}
		}
		PushMenu(objMenuGrid,{read_only: true, corner: "topright"})
		HEALSOUND
		if global.inCombat{ MakeTurnDelay(60,NextTurn)}else{MakeTurnDelay(60,PopMenu)}
		return
	}
	if global.lastselected != -1{struct.selected = global.lastselected}

	if struct.target == "enemy" {
		if struct.source == "djinni"{ 
			struct.on_cancel = method({djinn_id: struct.djinn_id},function(){ 
				global.djinnlist[djinn_id].spent = false;  
				global.djinnlist[djinn_id].ready = true; 
				global.djinnlist[djinn_id].just_unleashed = false})
		}
		PushMenu(objMonsterTarget, struct)
	} else {
		var _cfg = _BuildCharTargetConfig(struct)
		// Skip prompt if no valid targets exist (all filtered out)
		if !is_undefined(_cfg.filter) {
			var _any_valid = false
			for (var _fi = 0; _fi < array_length(global.players); _fi++) {
				if !_cfg.filter(_fi) { _any_valid = true; break }
			}
			if !_any_valid {
				_FinishCharTarget(struct)
				exit
			}
		}
		PushMenu(objMenuGrid, _cfg)
	}
}

/// @function _FireRepeats(struct, remaining, delay, total, loop_index)
/// @desc Fire one repeat hit then schedule the next via TurnDelay (survives outside the menu stack).
function _FireRepeats(_struct, _remaining, _delay, _total, _loop_index) {
    _loop_index = _loop_index ?? 0

    // Refresh troop list to current live monsters
    var _mcount = instance_number(objMonster)
    _struct.troop = []
    for (var _m = 0; _m < _mcount; _m++) { array_push(_struct.troop, instance_find(objMonster, _m)) }

    // Scatter: re-pick target for this hit
    if variable_struct_exists(_struct, "unleash") and variable_struct_exists(_struct.unleash, "scatter") and _struct.unleash.scatter {
        if _mcount > 0 {
            if variable_struct_exists(_struct.unleash, "scatter_any") and _struct.unleash.scatter_any {
                _struct.targets = [_struct.troop[irandom(_mcount - 1)]]
            } else {
                var _orig = _struct.targets[0]
                var _idx = 0
                for (var _mi = 0; _mi < _mcount; _mi++) { if _struct.troop[_mi] == _orig { _idx = _mi; break } }
                var _cands = []
                if _idx > 0 { array_push(_cands, _idx - 1) }
                array_push(_cands, _idx)
                if _idx < _mcount - 1 { array_push(_cands, _idx + 1) }
                _struct.targets = [_struct.troop[_cands[irandom(array_length(_cands) - 1)]]]
            }
        }
    }

    // If the struct has anim layers tagged for this loop, play them (fires_hit handles damage)
    // Otherwise fall back to direct DoDamage
    var _anim = _struct[$ "anim"]
    var _loop_layers = []
    if !is_undefined(_anim) {
        var _all = is_array(_anim) ? _anim : [_anim]
        for (var _ai = 0; _ai < array_length(_all); _ai++) {
            var _al = _all[_ai][$ "anim_loop"]
            if !is_undefined(_al) and _al == _loop_index { array_push(_loop_layers, _all[_ai]) }
        }
    }

    var _on_done = method({ s: _struct, r: _remaining, d: _delay, t: _total, li: _loop_index }, function() {
        // Check if anyone survives
        var _mcount = instance_number(objMonster)
        var _alive = false
        for (var _j = 0; _j < _mcount; _j++) {
            if s.troop[_j].monsterHealth != 0 { _alive = true; break }
        }
        //if !_alive { HandleVictory(); return }

        if r > 1 {
            MakeTurnDelay(d, method({s: s, r: r - 1, d: d, t: t, li: li + 1}, function() {
                _FireRepeats(s, r, d, t, li)
            }))
        } else {
            InjectLog("Hit " + string(t) + " times!")
            if s.source == "attack" { QueueOnAttack() }
            if array_length(global.attackQueue) > 0 {
                ProcessAttackQueue()
            } else {
                MakeTurnDelay(120, NextTurn)
            }
        }
    })

    if array_length(_loop_layers) > 0 {
        _struct.loop_index = _loop_index
        // Stamp the original targets onto layers that don't specify their own
        for (var _li = 0; _li < array_length(_loop_layers); _li++) {
            if is_undefined(_loop_layers[_li][$ "targets"]) and is_undefined(_loop_layers[_li][$ "target"]) {
                _loop_layers[_li].targets = _struct.targets
            }
        }
        AnimPlay(_loop_layers, _struct, _on_done)
    } else {
        DoDamage(_struct)
        _on_done()
    }
}

/// @function ApplyDamageToTargets(struct)
/// @desc Apply damage + statuses to an array of monster instances, then check victory or NextTurn.
function ApplyDamageToTargets(struct) {
	global.textdisplay = ""

	var _anim_layers = struct[$ "anim"]
	if !is_undefined(_anim_layers) {
		if !is_array(_anim_layers) { _anim_layers = [_anim_layers] }
		// Translate legacy flags
		for (var _li = 0; _li < array_length(_anim_layers); _li++) {
			var _layer = _anim_layers[_li]
			if is_undefined(_layer[$ "mode"]) {
				if _layer[$ "stagger_damage"] ?? false {
					_layer.mode = "stagger"
					_layer.stagger_delay = _layer[$ "stagger"] ?? 15
				} else if _layer[$ "single_anim"] ?? false {
					_layer.mode = "shared"
				}
			}
			// target_all: set targets to all alive monsters
			if _layer[$ "target_all"] ?? false {
				var _all_alive = []
				with (objMonster) { if monsterHealth > 0 { array_push(_all_alive, id) } }
				_layer.targets = _all_alive
			}
		}
		PopAll()
		AnimPlay(_anim_layers, struct, method({}, function() {
			//CheckVictory()
			MakeTurnDelay(60, NextTurn)
		}))
	} else {
		DoDamage(struct)
		//CheckVictory()
		PopAll()
		MakeTurnDelay(60, NextTurn)
	}
}


