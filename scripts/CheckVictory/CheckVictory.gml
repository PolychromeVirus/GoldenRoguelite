function CheckVictory(){
	var _any_alive = false
	var _count = instance_number(objMonster)
	for (var j = 0; j < _count; j++) {
		if instance_find(objMonster, j).monsterHealth != 0 {
			_any_alive = true
			break
		}
	}

	if _any_alive {
		global.inCombat = true
		global.pause = false
		NextTurn()
	} else {
		HandleVictory()
	}
}