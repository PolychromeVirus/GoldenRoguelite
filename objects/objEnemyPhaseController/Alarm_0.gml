if (mon_index >= array_length(mon_list)) {
	// Done — cleanup + callback
	FinishEnemyPhase()
	global.pause = false
	if (on_complete != undefined) { on_complete() }
	instance_destroy()
	exit
}

var _mon = mon_list[mon_index]
if (_mon.monsterHealth > 0) {
	ExecuteMonsterTurn(_mon)
}
mon_index++

// Check if all monsters dead (confusion kills, self-damage)
var _any_alive = false
with (objMonster) {
	if (monsterHealth > 0) { _any_alive = true; break }
}

if (!_any_alive) {
	mon_index = array_length(mon_list) // skip remaining
}

alarm[0] = 60 // ~0.75 sec between monsters
