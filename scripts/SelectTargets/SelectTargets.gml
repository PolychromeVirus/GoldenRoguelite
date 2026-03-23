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

	// If the packet carries its own anim, promote it to global.pendingAnim
	if variable_struct_exists(struct, "pendingAnim") {
		global.pendingAnim = struct.pendingAnim
		variable_struct_remove(struct, "pendingAnim")
	}

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

		ApplyDamageToTargets(struct)
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

/// @function _FireRepeats(struct, remaining, delay, total)
/// @desc Fire one repeat hit then schedule the next via TurnDelay (survives outside the menu stack).
function _FireRepeats(_struct, _remaining, _delay, _total) {
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

    DoDamage(_struct)

    // Check if anyone survives
    var _alive = false
    for (var _j = 0; _j < _mcount; _j++) {
        if _struct.troop[_j].monsterHealth != 0 { _alive = true; break }
    }
    if !_alive { HandleVictory(); return }

    if _remaining > 1 {
        MakeTurnDelay(_delay, method({s: _struct, r: _remaining - 1, d: _delay, t: _total}, function() {
            _FireRepeats(s, r, d, t)
        }))
    } else {
        InjectLog("Hit " + string(_total) + " times!")
        if _struct.source == "attack" { QueueOnAttack() }
        if array_length(global.attackQueue) > 0 {
            ProcessAttackQueue()
        } else {
            MakeTurnDelay(120, NextTurn)
        }
    }
}

/// @function ApplyDamageToTargets(struct)
/// @desc Apply damage + statuses to an array of monster instances, then check victory or NextTurn.
function ApplyDamageToTargets(struct) {
	global.textdisplay = ""

	var _anims = global.pendingAnim
	global.pendingAnim = undefined

	if _anims != undefined {
		if !is_array(_anims) { _anims = [_anims] }
		PopAll()
		var _targets = struct.targets

		// Check for stagger_damage
		var _stagger_dmg = false
		for (var _a = 0; _a < array_length(_anims); _a++) {
			if _anims[_a][$ "stagger_damage"] ?? false { _stagger_dmg = true; break }
		}

		// Step-major ordering when staggered, target-major otherwise
		var _first_hit = true
		if _stagger_dmg {
			for (var _a = 0; _a < array_length(_anims); _a++) {
				for (var _t = 0; _t < array_length(_targets); _t++) {
					var _anim = variable_clone(_anims[_a])
					if variable_struct_exists(_anim, "fires_hit") and _anim.fires_hit {
						_anim._stagger_target_index = _t
					}
					QueueAnim(_anim.type, _anim.element, _targets[_t], _anim)
				}
			}
		} else {
			for (var _t = 0; _t < array_length(_targets); _t++) {
				for (var _a = 0; _a < array_length(_anims); _a++) {
					var _anim = variable_clone(_anims[_a])
					if variable_struct_exists(_anim, "fires_hit") and _anim.fires_hit {
						if !_first_hit { _anim.fires_hit = false }
						_first_hit = false
					}
					QueueAnim(_anim.type, _anim.element, _targets[_t], _anim)
				}
			}
		}

		var _on_hit = _stagger_dmg
			? method({ s: struct, tgts: _targets }, function() {
				var _anim_inst = instance_find(objSpellAnimation, 0)
				var _copy = variable_clone(s)
				if instance_exists(_anim_inst) and variable_instance_exists(_anim_inst, "_barrage_hit_target")
					and instance_exists(_anim_inst._barrage_hit_target) {
					_copy.targets = [_anim_inst._barrage_hit_target]
				} else {
					var _ti = 0
					if instance_exists(_anim_inst) {
						var _step = _anim_inst._queue[_anim_inst._qi]
						_ti = _step[$ "_stagger_target_index"] ?? 0
					}
					_copy.targets = [tgts[_ti]]
				}
				DoDamage(_copy)
			})
			: method({ s: struct }, function() { DoDamage(s) })

		PlayAnimation(_on_hit, method({}, function() {
			CheckVictory()
			MakeTurnDelay(60, NextTurn)
		}))
	} else {
		DoDamage(struct)
		CheckVictory()
		PopAll()
		MakeTurnDelay(60, NextTurn)
	}
}


