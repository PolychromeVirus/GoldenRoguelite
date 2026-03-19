/// @function FinishEnemyPhase()
/// @desc Post-enemy-phase cleanup: root token tick + party wipe check
function FinishEnemyPhase() {
	
	
	
	// --- Party wipe check ---
	var _all_dead = true
	for (var _i = 0; _i < 4; _i++) {
		if global.players[_i].hp > 0 { _all_dead = false; break }
	}
	if _all_dead && !global.gameover {
		InjectLog("You died...")
		global.gameover = true
		global.gameover_timer = 240
		DeleteButtons()
		with (objMonster) { image_speed = 0 }
		var _bg = layer_background_get_id(layer_get_id("Background"))
		layer_background_blend(_bg, c_gray)
	}
}
