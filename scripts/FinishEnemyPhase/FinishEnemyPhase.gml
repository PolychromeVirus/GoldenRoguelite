/// @function FinishEnemyPhase()
/// @desc Post-enemy-phase cleanup: root token tick + party wipe check
function FinishEnemyPhase() {
	
	DeleteButtons()
	ClearOptions()
	DestroyAllBut()
	CreateOptions()
	
	// --- Party wipe check ---
	var _all_dead = true
	for (var _i = 0; _i < 4; _i++) {
		if global.players[_i].hp > 0 { _all_dead = false; break }
	}
	if _all_dead {
		InjectLog("Game Over!")
		global.inCombat = false
		global.pause = false
		room_goto(CharacterSelect)
	}
}
