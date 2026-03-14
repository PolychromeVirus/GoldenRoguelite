if (mon_index >= array_length(mon_list)) {
	// Done — cleanup + callback
	FinishEnemyPhase()
	global.pause = false
	if (on_complete != undefined) { on_complete() }
	
	var _poison_amt = 1
	var _poison_passive = CheckPassive("poison_buff")
	if (_poison_passive != undefined) { _poison_amt = _poison_passive.data.amount }
	for (var i = 0; i < array_length(global.players); i++){
		var _tick_dam = 0
		if global.players[i].poison { global.players[i].hp -= _poison_amt; _tick_dam += _poison_amt }
		if global.players[i].venom { global.players[i].hp -= 3; _tick_dam += 3 }
		if _tick_dam > 0 {
			global.players[i].flash_timer = 12
			instance_create_depth(0,0,-200,objDamageNumber,
				{ amount: _tick_dam, world_x: 5 + i * 400 + 100, world_y: 70, col: c_purple, gui_mode: true })
		}
		if global.players[i].hp <= 0 {
			global.players[i].hp = 0
			ClearAllTokens(global.players[i])
		}
		if array_contains(global.players[i].armor, FindItemID("Herbed Shirt")) and global.players[i].poison{ global.players[i].poison = false;global.players[i].venom = false; InjectLog(global.players[i].name + " nibbled on their shirt!")}
		if array_contains(global.players[i].armor, FindItemID("Herbed Shirt")) and global.players[i].venom{ global.players[i].poison = false;global.players[i].venom = false; InjectLog(global.players[i].name + " nibbled on their shirt!")}
	}
	with (objMonster) {
		if (monsterHealth > 0) {
			if poison { monsterHealth -= _poison_amt }
			if venom { monsterHealth -= 3 }
			if monsterHealth <= 0 { monsterHealth = 0 }
		}
	}
	if (global.inCombat) { CheckVictory() }

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
if (global.inCombat) { CheckVictory() }

alarm[0] = 60 // ~0.75 sec between monsters
