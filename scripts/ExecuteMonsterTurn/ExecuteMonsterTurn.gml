/// @function ExecuteMonsterTurn(mon_id)
/// @desc Phase 1: Resolve status checks, pick move, show announcement.
///       Returns a struct with move data for phase 2, or undefined if turn was skipped.
function ExecuteMonsterTurn(mon_id) {
	with (mon_id) {
		if monsterHealth <= 0 { return undefined }

		// --- Enemy DEF decay (move toward 0) ---
		if (defmod_fresh) { defmod_fresh = false }
		else if (defmod > 0) { defmod-- }
		else if (defmod < 0) { defmod++ }

		// --- Lose turn check ---
		if lose_turn {
			InjectLog(name + " lost their turn!")
			lose_turn = false
			return undefined
		}

		// --- Sleep check ---
		if sleep and !locked{
			if irandom(1) == 0 {
				InjectLog(name + " is asleep!")
				return undefined
			} else {
				InjectLog(name + " woke up!")
				sleep = false
			}
		}else if sleep and locked{
			InjectLog(name + " is sleeping deeply")
			locked = false
			return undefined
		}

		// --- Stun check ---
		if stun > 0 {
			if irandom(1) == 0 {
				InjectLog(name + " is stunned!")
				if !locked{stun--}
				return undefined
			} else {
				InjectLog(name + " attacks through stun!")
				if !locked{stun--}
			}
		}

		// --- Delude check ---
		var _deluded = false
		if delude {
			if irandom(2) == 0 { _deluded = true }
		}

		// --- Build weighted move list ---
		var _attacks = []
		var _grid = global.moveIDs
		for (var _r = 1; _r < ds_grid_height(_grid); _r++) {
			if _grid[# 0, _r] != name { continue }
			var _parts = (_grid[# 2, _r] == "") ? 1 : real(_grid[# 2, _r])
			var _move = {
				row: _r,
				movename: _grid[# 1, _r],
				vdam:   (_grid[# 3, _r] == "") ? 0 : real(_grid[# 3, _r]),
				madam:  (_grid[# 4, _r] == "") ? 0 : real(_grid[# 4, _r]),
				jdam:   (_grid[# 5, _r] == "") ? 0 : real(_grid[# 5, _r]),
				medam:  (_grid[# 6, _r] == "") ? 0 : real(_grid[# 6, _r]),
				dam:    (_grid[# 7, _r] == "") ? 0 : real(_grid[# 7, _r]),
				range:  (_grid[# 8, _r] == "") ? 1 : real(_grid[# 8, _r]),
				token:  _grid[# 9, _r],
				psy:    _grid[# 10, _r] == "TRUE",
				heal:   _grid[# 11, _r],
				double_hit: _grid[# 12, _r] == "TRUE",
				pierce: _grid[# 13, _r] == "TRUE",
				amt:    (_grid[# 14, _r] == "") ? 0 : real(_grid[# 14, _r]),
				targ:   (_grid[# 15, _r] == "") ? 0 : real(_grid[# 15, _r]),
				special: _grid[# 16, _r] == "TRUE"
			}
			for (var _p = 0; _p < _parts; _p++) {
				array_push(_attacks, _move)
			}
		}

		if array_length(_attacks) == 0 { return undefined }

		// Roll a 1-based index into the weighted move list (simulates d6 move table)
		var _roll = irandom(array_length(_attacks) - 1)
		if (CheckPassive("_mud") != undefined) { _roll = max(_roll - 1, 0) }
		var _move = _attacks[_roll]

		// Moloch passive: if rolled slot+1 matches nullified number, skip turn
		var _nullify = CheckPassive("nullify_move")
		if (_nullify != undefined and (_roll + 1) == _nullify.data.number) {
			InjectLog(name + " tries to act but is nullified by Moloch!")
			return undefined
		}
		//petra passive, reroll until the selected number isn't selected
		var _reroll = CheckPassive("reroll_move")
		if _reroll != undefined{
			while(_roll + 1 == _reroll.data.number){
				_roll = irandom(array_length(_attacks) - 1)
			}
			InjectLog(name + " tries to act but is forced to try again by Petra!")
		}

		// --- Special moves ---
		if _move.special {

			if _move.movename == "Flee" {
				if irandom(2) == 0{
					monsterHealth = 0
					sprite_index = FLED
					global.gold = global.goldAtCombatStart
					global.enemyFled = true
					InjectLog("Mimic ran away!")
					instance_create_depth(0,0,0,TurnDelay,{on_complete: function(){CheckVictory()}})
				}else{
					InjectLog("Mimic couldn't escape!")
				}
			}

			if _move.movename == "Mystic Call" {
				var _dead_slot = noone
				with (objMonster) {
					if monsterHealth <= 0 { _dead_slot = id; break }
				}

				if _dead_slot != noone {
					var _ball_names = ["Anger Ball", "Guardian Ball", "Refresh Ball", "Thunder Ball"]
					var _ballname = _ball_names[irandom(3)]

					var _template = undefined
					for (var _m = 0; _m < array_length(global.monsterlist); _m++) {
						if global.monsterlist[_m].name == _ballname {
							_template = variable_clone(global.monsterlist[_m])
							break
						}
					}

					if _template != undefined {
						_template.maxhp += 3 * global.hpcurse
						_template.monsterHealth = _template.maxhp
						_template.res += global.rescurse
						_template.atk += global.atkcurse

						with (_dead_slot) {
							name          = _template.name
							alias         = _template.alias
							sprite_index  = _template.alias
							image_index   = 0
							maxhp         = _template.maxhp
							monsterHealth = _template.monsterHealth
							weakness      = _template.weakness
							element       = _template.element
							atk           = _template.atk
							res           = _template.res
							boss          = _template.boss
							status_resist = _template[$ "status_resist"] ?? 0
							defmod = 0; atkmod = 0
							defmod_fresh = false; atkmod_fresh = false
							poison = false; venom = false; stun = 0
							sleep = false; delude = false; lose_turn = false
							psyseal = false; haunt = 0; frozen = 0
							dying = false; death_timer = -1
							image_alpha = 1; image_xscale = 1; image_yscale = 1
						}
						InjectLog(name + " calls " + _ballname + "!")
					}
				} else {
					InjectLog(name + " calls... but no one is missing!")
				}
				return undefined
			}

			InjectLog(name + " uses " + _move.movename + "!")
			return undefined
		}

		// --- Announce the move ---
		flash_timer = 15
		flash_color = c_white
		instance_create_depth(0, 0, -200, objDamageNumber, {
			text: _move.movename, world_x: x, world_y: y - sprite_height - 10,
			col: c_white, life: 90, no_rise: true
		})
		InjectLog(name + " uses " + _move.movename + "!")

		// --- Calculate base damage and determine element ---
		var _base_dam = _move.vdam + _move.madam + _move.jdam + _move.medam
		if _move.dam > 0 { _base_dam += _move.dam }
		_base_dam += atkmod + atk

		// Determine dominant element for weakness/resistance
		var _move_element = "Normal"
		var _max_edam = _move.dam
		if _move.vdam > _max_edam { _max_edam = _move.vdam; _move_element = "Venus" }
		if _move.madam > _max_edam { _max_edam = _move.madam; _move_element = "Mars" }
		if _move.jdam > _max_edam { _max_edam = _move.jdam; _move_element = "Jupiter" }
		if _move.medam > _max_edam { _max_edam = _move.medam; _move_element = "Mercury" }

		// Return data for phase 2
		return { mon: id, move: _move, base_dam: _base_dam, move_element: _move_element, deluded: _deluded }
	}
}

/// @function ApplyMonsterDamage(data)
/// @desc Phase 2: Apply the pre-calculated move effects (damage, statuses, heals)
function ApplyMonsterDamage(data) {
	var _mon = data.mon
	var _move = data.move
	var _base_dam = data.base_dam
	var _move_element = data.move_element
	var _deluded = data.deluded

	with (_mon) {
		// --- Self-damage (negative dam field) ---
		if _move.dam < 0 {
			monsterHealth -= abs(_move.dam)
			if monsterHealth <= 0 { monsterHealth = 0 }
			flash_timer = FLASH_DURATION; damage_timer = DAMAGE_DURATION; flash_color = ElementColor(_move_element)
			InjectLog(name + " takes " + string(abs(_move.dam)) + " self-damage!")
		}

		// --- Determine targets ---
		var _range = _move.range

		// Confusion: deluded monster hits left or right neighbor
		if _deluded and _range >= 1 {
			InjectLog("  " + name + " is confused!")
			var _all_mons = []
			var _self_idx = -1
			with (objMonster) {
				if id == _mon { _self_idx = array_length(_all_mons) }
				array_push(_all_mons, id)
			}
			var _neighbor = noone
			if irandom(1) == 0 {
				if _self_idx > 0 and _all_mons[_self_idx - 1].monsterHealth > 0 {
					_neighbor = _all_mons[_self_idx - 1]
				}
			} else {
				if _self_idx < array_length(_all_mons) - 1 and _all_mons[_self_idx + 1].monsterHealth > 0 {
					_neighbor = _all_mons[_self_idx + 1]
				}
			}
			if _neighbor != noone {
				var _confuse_dam = max(0, _base_dam)
				_neighbor.monsterHealth -= _confuse_dam
				_neighbor.flash_timer = FLASH_DURATION; _neighbor.damage_timer = DAMAGE_DURATION; _neighbor.flash_color = ElementColor(_move_element)
				if _neighbor.monsterHealth <= 0 { _neighbor.monsterHealth = 0 }
				InjectLog("  Hits " + _neighbor.name + " for " + string(_confuse_dam) + "!")
			} else {
				InjectLog("  " + name + " flails at nothing!")
			}
			return
		}

		// --- Apply to player targets (range > 0) ---
		var _total_damage_dealt = 0
		if _range >= 1 {
			var _alive = []
			for (var _i = 0; _i < 4; _i++) {
				if global.players[_i].hp > 0 { array_push(_alive, _i) }
			}
			if array_length(_alive) == 0 { return }

			var _player_targets = []
			if _range == 1 {
				array_push(_player_targets, _alive[irandom(array_length(_alive) - 1)])
			} else if _range == 3 {
				var _shuffled = array_create(array_length(_alive))
				array_copy(_shuffled, 0, _alive, 0, array_length(_alive))
				for (var _s = array_length(_shuffled) - 1; _s > 0; _s--) {
					var _j = irandom(_s)
					var _tmp = _shuffled[_s]
					_shuffled[_s] = _shuffled[_j]
					_shuffled[_j] = _tmp
				}
				for (var _s = 0; _s < min(3, array_length(_shuffled)); _s++) {
					array_push(_player_targets, _shuffled[_s])
				}
			} else {
				_player_targets = _alive
			}

			// Lure Cap provoke
			for (var _pr = 0; _pr < array_length(_player_targets); _pr++) {
				var _tgt = _player_targets[_pr]
				for (var _pi = 0; _pi < 4; _pi++) {
					if (_pi == _tgt) { continue }
					if (global.players[_pi].hp <= 0) { continue }
					if (variable_struct_exists(global.players[_pi], "provoke") && global.players[_pi].provoke) {
						if (irandom(3) == 0) {
							InjectLog("  " + global.players[_pi].name + "'s Lure Cap redirected an attack!")
							_player_targets[_pr] = _pi
							break
						}
					}
				}
			}

			var _hit_count = _move.double_hit ? (irandom(1) == 0 ? 2 : 1) : 1

			for (var _t = 0; _t < array_length(_player_targets); _t++) {
				var _pidx = _player_targets[_t]
				var _p = global.players[_pidx]

				if _p.cloak { continue }

				for (var _h = 0; _h < _hit_count; _h++) {
					var _final = _base_dam
					if !_move.pierce {
						_final -= (_p.def + _p.defmod)
					}
					if _move_element == "Venus" { _final -= _p.vres }
					else if _move_element == "Mars" { _final -= _p.mares }
					else if _move_element == "Jupiter" { _final -= _p.jres }
					else if _move_element == "Mercury" { _final -= _p.meres }
					_final = max(0, _final)

					if _final > 0 and CheckPassive("damage_cap_1") != undefined {
						_final = 1
					} else if _final > 0 and CheckPassive("damage_half") != undefined {
						_final = max(1, ceil(_final / 2))
					}

					if _final > 0 {
						_p.hp -= _final
						_p.flash_timer = FLASH_DURATION
						_total_damage_dealt += _final
						if _p.hp <= 0 {
							var _soulID = FindItemID("Soul Ring")
							var _soulIdx = array_get_index(_p.armor, _soulID)
							if (_soulIdx >= 0) {
								_p.hp = _p.hpmax
								array_delete(_p.armor, _soulIdx, 1)
								if (_soulIdx < array_length(_p.broken_armor)) {
									array_delete(_p.broken_armor, _soulIdx, 1)
								}
								array_push(global.discard, _soulID)
								InjectLog("  " + _p.name + "'s Soul Ring shattered, restoring them to full HP!")
								CreateDicePool()
							} else {
								_p.hp = 0
								ClearAllTokens(_p, true)
							}
						}
					}

					if _final > 0 and _p.reflect {
						monsterHealth = (max(0, monsterHealth - (_p.atk + _p.atkmod)))
					}
					var _gui_x = 237 + _pidx * 400
					var _gui_y = 165

					if _p.hp <= 0 {
						ClearAllTokens(_p, true)
						InjectLog("  " + _p.name + " is downed!")
						instance_create_depth(0,0,-200,objDamageNumber,
							{ amount: 0, world_x: _gui_x, world_y: _gui_y, gui_mode: true, icon: Death, life: 120 })
					} else if _final > 0 {
						instance_create_depth(0,0,-200,objDamageNumber,
							{ amount: _final, world_x: _gui_x, world_y: _gui_y, col: ElementColor(_move_element), gui_mode: true, life: 60 })
					}
				}
			}

			if _hit_count == 2 { InjectLog("  Double hit!") }

			if _move.token != "" {
				_EnemyApplyStatusToPlayers(_move, _player_targets)
			}

			if _move.heal == "dam" and _total_damage_dealt > 0 {
				monsterHealth = min(monsterHealth + _total_damage_dealt, maxhp)
				InjectLog("  " + name + " recovers " + string(_total_damage_dealt) + " HP!")
			}
		}

		// --- Apply to self (range 0) ---
		if _range == 0 {
			if _move.token != "" {
				_EnemyApplyTokenToMonster(id, _move.token, _move.amt)
			}
			if _move.heal != "" and _move.heal != "dam" {
				var _heal_amt = real(_move.heal)
				monsterHealth = min(monsterHealth + _heal_amt, maxhp)
				InjectLog("  " + name + " heals " + string(_heal_amt) + " HP!")
			}
		}

		// --- Apply to monster party (range -24) ---
		if _range == -24 {
			with (objMonster) {
				if monsterHealth <= 0 { continue }
				if _move.token != "" {
					_EnemyApplyTokenToMonster(id, _move.token, _move.amt)
				}
				if _move.heal != "" and _move.heal != "dam" {
					var _heal_amt = real(_move.heal)
					monsterHealth = min(monsterHealth + _heal_amt, maxhp)
				}
			}
			if _move.heal != "" and _move.heal != "dam" {
				InjectLog("  Heals all allies!")
			}
		}

		// --- Apply to other monsters (range -3) ---
		if _range == -3 {
			with (objMonster) {
				if id == _mon { continue }
				if monsterHealth <= 0 { continue }
				if _move.token != "" {
					_EnemyApplyTokenToMonster(id, _move.token, _move.amt)
				}
				if _move.heal != "" and _move.heal != "dam" {
					var _heal_amt = real(_move.heal)
					monsterHealth = min(monsterHealth + _heal_amt, maxhp)
				}
			}
		}

		// --- Apply to specific monster (range -1) ---
		if _range == -1 {
			var _target_idx = _move.targ
			var _count = 0
			with (objMonster) {
				if _count == _target_idx and monsterHealth > 0 {
					if _move.token != "" {
						_EnemyApplyTokenToMonster(id, _move.token, _move.amt)
					}
					if _move.heal != "" and _move.heal != "dam" {
						var _heal_amt = real(_move.heal)
						monsterHealth = min(monsterHealth + _heal_amt, maxhp)
						InjectLog("  Heals " + name + " for " + string(_heal_amt) + "!")
					}
				}
				_count++
			}
		}
		damvis = _total_damage_dealt
		drawdam = true
		timerstart = true
		// --- Enemy ATK decay (move toward 0) ---
		if (atkmod_fresh) { atkmod_fresh = false }
		else if (atkmod > 0) { atkmod-- }
		else if (atkmod < 0) { atkmod++ }
	}
}
