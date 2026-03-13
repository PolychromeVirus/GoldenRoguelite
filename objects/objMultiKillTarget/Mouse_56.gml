if instance_position(mouse_x, mouse_y, objConfirm) and clickable {
	global.textdisplay = ""
	if array_length(monsters) == 0 { exit }

	var mon = monsters[selected]

	// Show splash on each kill
	if variable_instance_exists(self, "splash_spr") and splash_spr != -1 {
		instance_create_depth(0, 0, -100, objSummonSplash, { spr: splash_spr })
	}

	// Instant kill
	mon.monsterHealth = 0
	mon.flash_timer = 12; mon.flash_color = c_white
	global.gold += 1
	instance_create_depth(0, 0, -200, objDamageNumber,
	{
		amount: 9999,
		world_x: mon.x,
		world_y: mon.y - mon.sprite_height,
		col: c_white
	})
	InjectLog(mon.name + " was slain by Charon!")
	array_push(killed, mon)
	kills_remaining--

	// Check if all monsters are dead (victory)
	var _any_alive = false
	var _mcount = instance_number(objMonster)
	for (var j = 0; j < _mcount; j++) {
		if instance_find(objMonster, j).monsterHealth > 0 {
			_any_alive = true
			break
		}
	}

	if !_any_alive {
		// Victory
		InjectLog("Combat Victory!")
		global.firstPlayer = global.turn
		global.inCombat = false
		global.pause = false
		CombatCleanup()
		ClearOptions()
		instance_create_depth(0, 0, -10, objPostBattle)
		instance_destroy()
		exit
	}

	if kills_remaining <= 0 {
		// Done picking — next turn
		global.pause = false
		instance_destroy()
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
		exit
	}

	// Rebuild monster list excluding dead and bosses
	monsters = []
	for (var i = 0; i < _mcount; i++) {
		var inst = instance_find(objMonster, i)
		if inst.monsterHealth > 0 and !inst.boss {
			array_push(monsters, inst)
		}
	}
	selected = 0

	// If no valid targets remain, finish early
	if array_length(monsters) == 0 {
		InjectLog("No more targets for Charon!")
		global.pause = false
		instance_destroy()
		instance_create_depth(0, 0, 0, TurnDelay, {wait: 30})
		exit
	}
}
