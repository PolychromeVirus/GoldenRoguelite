
/// @func SplashWithResist(struct, source, tempdam, monster)
/// @desc Apply splash damage with weakness/resistance. source is the sub-struct (unleash or onConfirm) containing splash_ratio/splash_element.
function SplashWithResist(_struct, _source, _tempdam, _mon) {
	var _base = max(1, ceil(_tempdam * _source.splash_ratio))
	var _modif = 0
	var _caster = _struct.caster
	var _elem = variable_struct_exists(_source, "splash_element") ? _source.splash_element : _struct.dmgtype
	if _caster.name == "Jules"{_elem = "normal"}
	var _resist = (string_lower(_mon.element) == string_lower(_elem)) ? _mon.res : 0
	if string_lower(_elem) == string_lower(_mon.weakness) { _resist = 0 }
	if string_lower(_elem) == "mercury" and _mon.mark{_resist = 0;_modif = max(1, floor(_caster.mercury / 2))}
	
	if string_lower(_elem) == string_lower(_mon.weakness) and _base > 0 {
		if _elem == "venus"   { _modif = max(1, floor(_caster.venus / 2)) }
		if _elem == "mars"    { _modif = max(1, floor(_caster.mars / 2)) }
		if _elem == "jupiter" { _modif = max(1, floor(_caster.jupiter / 2)) }
		if _elem == "mercury" { _modif = max(1, floor(_caster.mercury / 2)) }
	}
	return max(1, _base - _resist + _modif)
}

function DoDamage(struct){
	// Hit sound based on attack source
	switch struct.source {
		case "attack":
		case "onAttack": HITSOUND;   break
		case "psynergy": if struct.num > 1 { BIGHITMULT } else { BIGHIT } break
		case "summon":   SUMMONHIT;  break
		case "djinni":   BIGHIT;     break
	}

	var dam      = struct.dam
	var dmgtype  = struct.dmgtype
	var pierce   = struct.pierce
	var slash    = struct.slash
	var selected = struct.selected
	var targets = struct.targets
	var troop = struct.troop
	
	if struct.caster.name == "Jules"{dmgtype = "normal"}

	var _status_inflicted = false

    // Determine element color for damage numbers
    var _dam_col = ElementColor(dmgtype)
	var tempdam = dam
    // Deal damage — dam is fully pre-calculated by the caller
    for (var i = 0; i < array_length(targets); i++) {
        var mon = targets[i]
        if mon.monsterHealth <= 0 { continue }
		tempdam = dam
		
		//subtract enemy defense unless attack penetrates
		if !pierce and tempdam > 0{tempdam -= mon.defmod}

        // Element resistance: -1 if monster's element matches damage element
        var _resist = (string_lower(mon.element) == string_lower(dmgtype)) ? mon.res : 0
		if string_lower(mon.element) == "mercury" and mon.mark and string_lower(dmgtype) == "mercury"{_resist = 0}
		if string_lower(dmgtype) == string_lower(mon.weakness){_resist = 0}
		
		if slash {tempdam += mon.defmod}
	var modif = 0	
	if string_lower(dmgtype) == string_lower(mon.weakness) and tempdam > 0{ 
			
			
			if dmgtype == "venus"{ modif = max(1,floor(struct.caster.venus / 2)) }
			if dmgtype == "mars"{ modif = max(1,floor(struct.caster.mars / 2)) }
			if dmgtype == "jupiter"{ modif = max(1,floor(struct.caster.jupiter / 2)) }
			if dmgtype == "mercury"{ modif = max(1,floor(struct.caster.mercury / 2)) }
			if string_lower(dmgtype) == "mercury" and mon.mark {modif = max(1,floor(struct.caster.mercury / 2))}
			}
		
        var _show_dam = 0
        if tempdam >= 9999 and !mon.boss{
            // Instant kill (Charon)
            mon.monsterHealth = 0
            mon.flash_timer = 12; mon.flash_color = _dam_col
            global.gold += 1
            _show_dam = 9999
        } else if tempdam >= 9999 and mon.boss {
            var final_dam = 0
            mon.flash_timer = 12; mon.flash_color = _dam_col
            _show_dam = final_dam
			InjectLog("The boss resisted death!")

        }else if tempdam > 0 {
            var final_dam = max(1, tempdam - _resist + modif)
            mon.monsterHealth -= final_dam
            mon.flash_timer = 12; mon.flash_color = _dam_col
            _show_dam = final_dam

            if mon.monsterHealth <= 0 {
                mon.monsterHealth = 0
                global.gold += 1
				audio_stop_sound(DeathSoundMedium);audio_play_sound(DeathSoundMedium,1,0)
            }
        }
		var _icon_x = mon.x
		var _icon_y = mon.y - mon.sprite_height
		if mon.monsterHealth <= 0 {
			instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: Death })
        } else if _show_dam > 0 {
            instance_create_depth(0,0,-200,objDamageNumber,
            {
                amount: _show_dam,
                world_x: _icon_x,
                world_y: _icon_y,
                col: _dam_col
            })
        }

		// Apply status inflictions to surviving targets
		var attempt = true
		var attempted = false
		var stats = variable_clone(struct.statuses)

		if variable_struct_exists(stats, "inflict_mark") { mon.mark = stats.inflict_mark}
		if mon.boss{attempt = irandom(1) == 1}
		if mon.monsterHealth > 0 and attempt{
			if variable_struct_exists(stats, "inflict_poison") { mon.poison = stats.inflict_poison; attempted = true; _status_inflicted = true; instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: Poison }) }
			if variable_struct_exists(stats, "inflict_venom") { mon.venom = stats.inflict_venom; attempted = true; _status_inflicted = true; instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: Poison_Flow }) }
			if variable_struct_exists(stats, "inflict_stun") { mon.stun = stats.inflict_stun; attempted = true; _status_inflicted = true; instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: Bolt }) }
			if variable_struct_exists(stats, "inflict_sleep") { mon.sleep = stats.inflict_sleep; attempted = true; _status_inflicted = true; instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: Sleep }) }
			if variable_struct_exists(stats, "inflict_delude") { mon.delude = stats.inflict_delude; attempted = true; _status_inflicted = true; instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: Delude }) }
			if variable_struct_exists(stats, "inflict_psyseal") { mon.psyseal = stats.inflict_psyseal; attempted = true; _status_inflicted = true; instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: Psy_Seal }) }
			if variable_struct_exists(stats, "inflict_lose_turn") and stats.inflict_lose_turn > 0 { mon.lose_turn = true; stats.inflict_lose_turn--; attempted = true; _status_inflicted = true }


		}else if attempted and !attempt{InjectLog(mon.name + " resisted status!")}
	    if variable_struct_exists(stats, "inflict_defdown") { mon.defmod -= stats.inflict_defdown; mon.defmod_fresh = bool(stats.inflict_defdown); if stats.inflict_defdown > 0 { instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: defense_down }) } }
		if variable_struct_exists(stats, "inflict_atkdown") { mon.atkmod -= stats.inflict_atkdown; mon.atkmod_fresh = bool(stats.inflict_atkdown); if stats.inflict_atkdown > 0 { instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, icon: attack_down }) } }
		if variable_struct_exists(stats, "inflict_clearstats") {
			mon.atkmod = 0
			mon.defmod = 0

		}
		var _hauntatt = irandom(1)
		if variable_struct_exists(stats, "inflict_haunt") and _hauntatt { mon.haunt = stats.inflict_haunt; attempted = true}
		else if variable_struct_exists(stats, "inflict_haunt") and !_hauntatt{ InjectLog(mon.name + " resisted a spirit!") }

		if variable_struct_exists(stats, "locked") and stats.locked == true { mon.locked = struct.statuses.locked}
	}
	if _status_inflicted { INFLICT }

	var _unleash = struct.unleash
	// Unleash: instant kill non-boss targets
	if variable_struct_exists(_unleash, "instant_kill") and _unleash.instant_kill {
		for (var _uk = 0; _uk < array_length(targets); _uk++) {
			var _mon = targets[_uk]
			if _mon.monsterHealth > 0 and !_mon.boss {
				_mon.monsterHealth = 0
				_mon.flash_timer = 12; _mon.flash_color = _dam_col
				global.gold += 1
				instance_create_depth(0,0,-200,objDamageNumber,
				{ amount: 9999, world_x: _mon.x, world_y: _mon.y - _mon.sprite_height, col: c_white })
				InjectLog(_mon.name + " was instantly defeated!")
			}
		}
	}

	// Unleash: heal attacker HP/PP

	var _caster = struct.caster
	if variable_struct_exists(_unleash, "heal_hp_ratio") and _unleash.heal_hp_ratio > 0 {
		var _heal = ceil(tempdam * _unleash.heal_hp_ratio)
		_caster.hp = min(_caster.hp + _heal, _caster.hpmax)
		InjectLog(_caster.name + " recovers " + string(_heal) + " HP!")
	}
	if variable_struct_exists(_unleash, "heal_pp_ratio") and _unleash.heal_pp_ratio > 0 {
		var _ppheal = floor(tempdam * _unleash.heal_pp_ratio)
		_caster.pp = min(_caster.pp + _ppheal, _caster.ppmax)
		InjectLog(_caster.name + " recovers " + string(_ppheal) + " PP!")
	}
	if variable_struct_exists(_unleash, "heal_hp_flat") and _unleash.heal_hp_flat > 0 {
		_caster.hp = min(_caster.hp + _unleash.heal_hp_flat, _caster.hpmax)
		InjectLog(_caster.name + " recovers " + string(_unleash.heal_hp_flat) + " HP!")
	}
	if variable_struct_exists(_unleash, "heal_pp_flat") and _unleash.heal_pp_flat > 0 {
		_caster.pp = min(_caster.pp + _unleash.heal_pp_flat, _caster.ppmax)
		InjectLog(_caster.name + " recovers " + string(_unleash.heal_pp_flat) + " PP!")
	}
	
	
	

	// Unleash: splash damage to neighbors
	if variable_struct_exists(_unleash, "splash_ratio") and _unleash.splash_ratio > 0 {
		var _splash_col = variable_struct_exists(_unleash, "splash_element") ? ElementColor(_unleash.splash_element) : _dam_col
		if _caster.name == "Jules"{_splash_col = c_white}
		
		// Splash left neighbor
		if selected - 1 >= 0 and troop[selected - 1].monsterHealth > 0 {
			var _sn = troop[selected - 1]
			var _sd = SplashWithResist(struct, _unleash, tempdam, _sn)
			_sn.monsterHealth -= _sd
			_sn.flash_timer = 12; _sn.flash_color = _splash_col
			InjectLog(_sn.name + " takes " + string(_sd) + " splash damage!")
			if _sn.monsterHealth <= 0 { _sn.monsterHealth = 0; global.gold += 1 }
			instance_create_depth(0,0,-200,objDamageNumber,
				{ amount: _sd, world_x: _sn.x, world_y: _sn.y - _sn.sprite_height, col: _splash_col })
		}
		// Splash right neighbor
		if selected + 1 < array_length(troop) and troop[selected + 1].monsterHealth > 0 {
			var _sn = troop[selected + 1]
			var _sd = SplashWithResist(struct, _unleash, tempdam, _sn)
			_sn.monsterHealth -= _sd
			_sn.flash_timer = 12; _sn.flash_color = _splash_col
			InjectLog(_sn.name + " takes " + string(_sd) + " splash damage!")
			if _sn.monsterHealth <= 0 { _sn.monsterHealth = 0; global.gold += 1 }
			instance_create_depth(0,0,-200,objDamageNumber,
				{ amount: _sd, world_x: _sn.x, world_y: _sn.y - _sn.sprite_height, col: _splash_col })
		}
	}
	// Unleash: Cloud Wand splash stun to neighbors
	if variable_struct_exists(_unleash, "splash_element") and _unleash.splash_element == "stun" {
		if selected - 1 >= 0 and troop[selected - 1].monsterHealth > 0 {
			troop[selected - 1].stun = 3
			InjectLog(troop[selected - 1].name + " is stunned!")
		}
		if selected + 1 < array_length(troop) and troop[selected + 1].monsterHealth > 0 {
			troop[selected + 1].stun = 3
			InjectLog(troop[selected + 1].name + " is stunned!")
		}
	}

	// Unleash repeater: queue a full replay via root repeater (e.g. Echo djinn)
	if variable_struct_exists(_unleash, "repeater") and _unleash.repeater > 0 {
		struct.repeater += _unleash.repeater
		_unleash.repeater = 0
	}

	// Splash statuses to neighbors (e.g. Shine's delusion)
	if variable_struct_exists(struct, "splash_statuses") {
		var _ss = struct.splash_statuses
		for (var _si = -1; _si <= 1; _si += 2) {
			var _idx = selected + _si
			if _idx >= 0 and _idx < array_length(troop) and troop[_idx].monsterHealth > 0 {
				var _sn = troop[_idx]
				var _attempt = true
				if _sn.boss { _attempt = irandom(1) == 1 }
				if _attempt {
					if variable_struct_exists(_ss, "inflict_delude") { _sn.delude = _ss.inflict_delude; InjectLog(_sn.name + " is deluded!") }
					if variable_struct_exists(_ss, "inflict_poison") { _sn.poison = _ss.inflict_poison; InjectLog(_sn.name + " is poisoned!") }
					if variable_struct_exists(_ss, "inflict_sleep") { _sn.sleep = _ss.inflict_sleep; InjectLog(_sn.name + " fell asleep!") }
					if variable_struct_exists(_ss, "inflict_stun") { _sn.stun = _ss.inflict_stun; InjectLog(_sn.name + " is stunned!") }
				}
			}
		}
	}

	// Mold: each alive neighbour of target hits the target with a random attack
	if variable_struct_exists(struct, "mold") and struct.mold {
		for (var _si = -1; _si <= 1; _si += 2) {
			var _idx = selected + _si
			if _idx >= 0 and _idx < array_length(troop) and troop[_idx].monsterHealth > 0 {
				var _neighbor = troop[_idx]
				// Roll a random attack from the neighbour's move table
				var _nattacks = []
				var _grid = global.moveIDs
				for (var _r = 1; _r < ds_grid_height(_grid); _r++) {
					if _grid[# 0, _r] == _neighbor.name {
						array_push(_nattacks, {
							dam: (_grid[# 7, _r] == "") ? 0 : real(_grid[# 7, _r]),
							vdam: (_grid[# 3, _r] == "") ? 0 : real(_grid[# 3, _r]),
							madam: (_grid[# 4, _r] == "") ? 0 : real(_grid[# 4, _r]),
							jdam: (_grid[# 5, _r] == "") ? 0 : real(_grid[# 5, _r]),
							medam: (_grid[# 6, _r] == "") ? 0 : real(_grid[# 6, _r])
						})
					}
				}
				if array_length(_nattacks) > 0 {
					var _nmove = _nattacks[irandom(array_length(_nattacks) - 1)]
					var _ndam = max(0, _nmove.dam) + _nmove.vdam + _nmove.madam + _nmove.jdam + _nmove.medam
					_ndam += _neighbor.atkmod + _neighbor.atk
					_ndam = max(0, _ndam)
					var _target = troop[selected]
					if _target.monsterHealth > 0 {
						_target.monsterHealth -= _ndam
						_target.flash_timer = 12; _target.flash_color = c_red
						if _target.monsterHealth <= 0 { _target.monsterHealth = 0; global.gold += 1 }
						InjectLog(_neighbor.name + " strikes " + _target.name + " for " + string(_ndam) + "!")
						instance_create_depth(0, 0, -200, objDamageNumber,
							{ amount: _ndam, world_x: _target.x, world_y: _target.y - _target.sprite_height, col: c_red })
					}
				}
			}
		}
	}

	// onConfirm: splash damage to neighbors (spell effects like Diamond Dust)
	var _onConfirm = struct.onConfirm
	if variable_struct_exists(_onConfirm, "splash_ratio") and _onConfirm.splash_ratio > 0 {
		var _oc_splash_col = variable_struct_exists(_onConfirm, "splash_element") ? ElementColor(_onConfirm.splash_element) : _dam_col
		if selected - 1 >= 0 and troop[selected - 1].monsterHealth > 0 {
			var _sn = troop[selected - 1]
			var _sd = SplashWithResist(struct, _onConfirm, tempdam, _sn)
			_sn.monsterHealth -= _sd
			_sn.flash_timer = 12; _sn.flash_color = _oc_splash_col
			InjectLog(_sn.name + " takes " + string(_sd) + " splash damage!")
			if _sn.monsterHealth <= 0 { _sn.monsterHealth = 0; global.gold += 1 }
			instance_create_depth(0,0,-200,objDamageNumber,
				{ amount: _sd, world_x: _sn.x, world_y: _sn.y - _sn.sprite_height, col: _oc_splash_col })
		}
		if selected + 1 < array_length(troop) and troop[selected + 1].monsterHealth > 0 {
			var _sn = troop[selected + 1]
			var _sd = SplashWithResist(struct, _onConfirm, tempdam, _sn)
			_sn.monsterHealth -= _sd
			_sn.flash_timer = 12; _sn.flash_color = _oc_splash_col
			InjectLog(_sn.name + " takes " + string(_sd) + " splash damage!")
			if _sn.monsterHealth <= 0 { _sn.monsterHealth = 0; global.gold += 1 }
			instance_create_depth(0,0,-200,objDamageNumber,
				{ amount: _sd, world_x: _sn.x, world_y: _sn.y - _sn.sprite_height, col: _oc_splash_col })
		}
	}

	// Daedalus cascade: spread half damage outward from selected target
	if (variable_global_exists("daedalusCascade") and global.daedalusCascade) {
		global.daedalusCascade = false
		var _cascade_dam = max(1, ceil(tempdam / 2))
		// Spread left from selected
		for (var _c = selected - 1; _c >= 0; _c--) {
			if (troop[_c].monsterHealth <= 0) { continue }
			troop[_c].monsterHealth -= _cascade_dam
			troop[_c].flash_timer = 12; troop[_c].flash_color = _dam_col
			InjectLog(troop[_c].name + " takes " + string(_cascade_dam) + " cascade damage!")
			if (troop[_c].monsterHealth <= 0) {
				troop[_c].monsterHealth = 0
				global.gold += 1
			}
			_cascade_dam = max(0, ceil(_cascade_dam / 2))
		}
		// Spread right from selected
		_cascade_dam = max(0, ceil(tempdam / 2))
		for (var _c = selected + 1; _c < array_length(troop); _c++) {
			if (troop[_c].monsterHealth <= 0) { continue }
			troop[_c].monsterHealth -= _cascade_dam
			troop[_c].flash_timer = 12; troop[_c].flash_color = _dam_col
			InjectLog(troop[_c].name + " takes " + string(_cascade_dam) + " cascade damage!")
			if (troop[_c].monsterHealth <= 0) {
				troop[_c].monsterHealth = 0
				global.gold += 1
			}
			_cascade_dam = max(1, ceil(_cascade_dam / 2))
		}
	}

	// Repeater: replay the full damage pipeline again (e.g. Echo djinn)
	if struct.repeater > 0 {
		struct.repeater--
		DoDamage(struct)
	}
}