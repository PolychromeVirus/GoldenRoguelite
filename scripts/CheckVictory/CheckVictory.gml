function CheckVictory(){
	// --- Monster wipe check (poison/venom kills) ---
	var _any_monster_alive = false
	var _mon_count = instance_number(objMonster)
	for (var _m = 0; _m < _mon_count; _m++) {
		if instance_find(objMonster, _m).monsterHealth != 0 {
			_any_monster_alive = true
			break
		}
	}
	if (_mon_count > 0 and !_any_monster_alive) {
		// Wait for all death animations to finish before victory
		var _max_death = 0
		for (var _m = 0; _m < _mon_count; _m++) {
			var _mon = instance_find(objMonster, _m)
			if _mon.dying and _mon.death_timer > _max_death {
				_max_death = _mon.death_timer
			}
		}
		var _wait = max(120, _max_death + 15)
		MakeTurnDelay(_wait, HandleVictory)
		return true
	}

	// --- Party wipe check ---
	var _all_dead = true
	for (var _w = 0; _w < 4; _w++) {
		if global.players[_w].hp > 0 { _all_dead = false; break }
	}
	if _all_dead && !global.gameover {
		InjectLog("You died...")
		global.gameover = true
		global.gameover_timer = 240
		
		for (var i = 0; i < array_length(global.players); ++i) {
				var _curr = global.players[i]
	
				for (var j = 0; j < array_length(_curr.djinn); ++j) {
				var _dj = global.djinnlist[_curr.djinn[j]]
	
				_dj.spent = false
				_dj.ready = true
	
	
				}
	
			}

CreateDicePool()
		
		with (objMonster) { image_speed = 0 }
		var _bg = layer_background_get_id(layer_get_id("Background"))
		layer_background_blend(_bg, c_gray)
		exit
	}
	
	return false
	
}
