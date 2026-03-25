if (mon_index >= array_length(mon_list)) {
	// Done — cleanup + callback
	FinishEnemyPhase()
	if (on_complete != undefined) { on_complete() }

	var _poison_amt = 1
	var _poison_passive = CheckPassive("poison_buff")
	if (_poison_passive != undefined) { _poison_amt = _poison_passive.data.amount }
	for (var i = 0; i < array_length(global.players); i++){
		var _tick_dam = 0
		if global.players[i].poison { global.players[i].hp -= _poison_amt; _tick_dam += _poison_amt }
		if global.players[i].venom { global.players[i].hp -= 3; _tick_dam += 3 }
		if _tick_dam > 0 {
			global.players[i].flash_timer = FLASH_DURATION
			instance_create_depth(0,0,-200,objDamageNumber,
				{ amount: _tick_dam, world_x: 5 + i * 400 + 100, world_y: 70, col: c_purple, gui_mode: true, life: 60 })
		}
		if global.players[i].hp <= 0 {
			global.players[i].hp = 0
			ClearAllTokens(global.players[i], true)
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
	if (global.inCombat) { //CheckVictory() 
		}

	instance_destroy()
	exit
}

// --- Phase 0: Announce (pick move, flash monster, show move name) ---
if phase == 0 {
	var _mon = mon_list[mon_index]
	if (_mon.monsterHealth > 0) {
		pending_data = ExecuteMonsterTurn(_mon)
	} else {
		pending_data = undefined
	}

	if pending_data != undefined {
		// Move was announced — wait then apply damage
		phase = 1
		alarm[0] = 30 // ~0.5 sec to read the move name
	} else {
		// Turn was skipped (sleep/stun/etc) — move to next monster
		mon_index++
		alarm[0] = 30
	}
	exit
}

// --- Phase 1: Apply damage ---
if phase == 1 {
	ApplyMonsterDamage(pending_data)
	pending_data = undefined
	phase = 0
	mon_index++

	// Check if all monsters dead (confusion kills, self-damage)
	var _any_alive = false
	with (objMonster) {
		if (monsterHealth > 0) { _any_alive = true; break }
	}
	if (!_any_alive) {
		mon_index = array_length(mon_list)
	}
	if (global.inCombat) { //CheckVictory() 
	}

	alarm[0] = 45 // ~0.75 sec before next monster
}
