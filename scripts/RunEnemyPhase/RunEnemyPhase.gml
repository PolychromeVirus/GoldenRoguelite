/// @function RunEnemyPhase(bosses_only, on_complete)
/// @param {bool} bosses_only  true = only boss monsters act; false = only non-boss monsters act
/// @param {function} on_complete  callback when phase finishes
function RunEnemyPhase(bosses_only, on_complete=undefined) {
	// Check passive skip effects
	if !bosses_only{
		for (var i = 0; i < array_length(global.players); ++i) {

			var temphp = variable_clone(global.players[i].hp)			
		
			if variable_struct_exists(global.players[i].delaydata,"healing"){
				var _delay_heal = global.players[i].delaydata.healing
				if (global.players[i].halfheal and _delay_heal > 0) { _delay_heal = floor(_delay_heal / 2) }
				global.players[i].hp = min(temphp + _delay_heal, global.players[i].hpmax)
				if variable_struct_exists(global.players[i].delaydata,"revive") and global.players[i].delaydata.revive {InjectLog(global.players[i].name + " is revived!")}
			}
				
			global.players[i].delaydata = {}
			
		}
	}
	var act = true
	if bosses_only and CheckPassive("skip_bosses") != undefined {
		InjectLog("Bosses held in place!")
		act = false
		if (on_complete != undefined) { on_complete() }
		return
	}
	
	if !bosses_only and CheckPassive("skip_enemies") != undefined {
		InjectLog("Enemies held in place!")
		act = false
		if (on_complete != undefined) { on_complete() }
		return
	}

	// Build list of monsters that should act
	var _mon_list = []
	if act{
		with (objMonster) {
			if monsterHealth <= 0 { continue }
			if bosses_only and !boss { continue }
			array_push(_mon_list, id)
		}
	}
	if array_length(_mon_list) == 0 {
		FinishEnemyPhase()
		if (on_complete != undefined) { on_complete() }
		return
	}

	// Create async controller to step through monsters one at a time
	instance_create_depth(0, 0, 0, objEnemyPhaseController, {
		mon_list: _mon_list,
		on_complete: on_complete
	})
}

/// @function _EnemyApplyStatusToPlayers(move, player_indices)
/// @desc Apply status token from an enemy move to targeted players
function _EnemyApplyStatusToPlayers(move, player_indices) {
	var _token = move.token
	var _guaranteed = (string_pos("+", _token) > 0)
	var _base = _guaranteed ? string_replace(_token, "+", "") : _token

	for (var _i = 0; _i < array_length(player_indices); _i++) {
		var _pidx = player_indices[_i]
		var _p = global.players[_pidx]
		if _p.hp <= 0 { continue }
		if _p.cloak { continue }
		if CheckPassive("_vine") != undefined { continue }
		// Attempt check for non-guaranteed
		// Silk Robe: attempt rolls must roll 6 to succeed
		if !_guaranteed {
			var _hasSilk = array_contains(_p.armor, FindItemID("Silk Robe"))
			if (_hasSilk) {
				if (irandom(5) != 0) { continue } // only 6 succeeds (1 in 6)
			} else {
				if (irandom(1) == 0) { continue } // normal 50% chance
			}
		}
		

		var _icon_x = 237 + _pidx * 400
		var _icon_y = 165

		switch _base {
			case "poi":
				_p.poison = true
				InjectLog("  " + _p.name + " is poisoned!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: Poison })
				break
			case "ven":
				_p.venom = true
				InjectLog("  " + _p.name + " is envenomed!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: Poison })
				break
			case "stun":
				_p.stun = 3
				InjectLog("  " + _p.name + " is stunned!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: Bolt })
				break
			case "sleep":
				_p.sleep = true
				InjectLog("  " + _p.name + " fell asleep!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: Sleep })
				break
			case "psy":
				_p.psyseal = true
				InjectLog("  " + _p.name + "'s psynergy is sealed!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: Psy_Seal })
				break
			case "defd":
				_p.defmod -= move.amt
				_p.defmod_fresh = true
				InjectLog("  " + _p.name + "'s DEF decreased!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: defense_down })
				break
			case "atkd":
				_p.atkmod -= move.amt
				_p.atkmod_fresh = true
				InjectLog("  " + _p.name + "'s ATK decreased!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: attack_down })
				break
			case "defu":
				_p.defmod += move.amt
				_p.defmod_fresh = true
				InjectLog("  " + _p.name + "'s DEF increased!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: defense_up })
				break
			case "atku":
				_p.atkmod += move.amt
				_p.atkmod_fresh = true
				InjectLog("  " + _p.name + "'s ATK increased!")
				instance_create_depth(0,0,-200,objDamageNumber, { amount: 0, world_x: _icon_x, world_y: _icon_y, gui_mode: true, icon: attack_up })
				break
			case "bre":
				_p.atkmod = 0
				_p.defmod = 0
				InjectLog("  " + _p.name + "'s stat changes are reset!")
				break
			case "djinn":
				// Put 1 random ready djinni into recovery
				var _ready = []
				for (var _d = 0; _d < array_length(_p.djinn); _d++) {
					if global.djinnlist[_p.djinn[_d]].ready {
						array_push(_ready, _d)
					}
				}
				if array_length(_ready) > 0 {
					var _pick = _ready[irandom(array_length(_ready) - 1)]
					var _dj = global.djinnlist[_p.djinn[_pick]]
					_dj.ready = false
					_dj.spent = false
					InjectLog("  " + _p.name + "'s djinni is exhausted!")
				}
				break
			case "lose":
				InjectLog("  " + _p.name + " loses a turn! (not yet implemented)")
				break
		}
	}
}

/// @function _EnemyApplyTokenToMonster(monster_id, token, amt)
/// @desc Apply a stat token to a monster instance
function _EnemyApplyTokenToMonster(monster_id, token, amt) {
	switch token {
		case "defu":
			monster_id.defmod += amt
			monster_id.defmod_fresh = true
			InjectLog("  " + monster_id.name + "'s DEF increased by " + string(amt) + "!")
			break
		case "defd":
			monster_id.defmod -= amt
			monster_id.defmod_fresh = true
			InjectLog("  " + monster_id.name + "'s DEF decreased by " + string(amt) + "!")
			break
		case "atku":
			monster_id.atkmod += amt
			monster_id.atkmod_fresh = true
			InjectLog("  " + monster_id.name + "'s ATK increased by " + string(amt) + "!")
			break
		case "atkd":
			monster_id.atkmod -= amt
			monster_id.atkmod_fresh = true
			InjectLog("  " + monster_id.name + "'s ATK decreased by " + string(amt) + "!")
			break
	}
}



