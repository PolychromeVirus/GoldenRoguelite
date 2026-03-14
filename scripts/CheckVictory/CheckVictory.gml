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
		HandleVictory()
		exit
	}

	// --- Party wipe check ---
	var _all_dead = true
	for (var _w = 0; _w < 4; _w++) {
		if global.players[_w].hp > 0 { _all_dead = false; break }
	}
	if _all_dead {
		InjectLog("You died...")
		global.gameover = true
		global.gameover_timer = 300
		DeleteButtons()
		with (objMonster) { image_speed = 0 }
		var _bg = layer_background_get_id(layer_get_id("Background"))
		layer_background_blend(_bg, c_gray)
		exit
	}
}