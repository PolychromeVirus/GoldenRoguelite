function NextTurn(){

	// Clear any stale menus left on the stack
	while array_length(global.menu_stack) > 0 { PopMenu() }

	// --- Extra turn: skip djinn recovery, PP regen, boss phase — just reroll and go ---
	if global.players[global.turn].extraTurns > 0 {
		global.players[global.turn].extraTurns--
		global.players[global.turn].dicepool = RollDice(global.players[global.turn])
		CreateOptions()
		exit
	}

	// --- Djinn recovery for outgoing player ---
	var _cp = global.players[global.turn]
	// Spent → Ready (first one only)
	for (var _d = 0; _d < array_length(_cp.djinn); _d++){
		var _dj = global.djinnlist[_cp.djinn[_d]]
		if (!_dj.ready && _dj.spent && !_dj.just_unleashed && _dj.can_recover){
			_dj.ready = true
			_dj.spent = false
			break
		}
	}
	if !global.justSummoned{
	// Recovery → Spent (first one only)
		for (var _d = 0; _d < array_length(_cp.djinn); _d++){
			var _dj = global.djinnlist[_cp.djinn[_d]]
			if (!_dj.ready && !_dj.spent){
				_dj.ready = false
				_dj.spent = true
				break
			}
		}
	}
	

	_AdvanceTurn()

}


function _AdvanceTurn(){
	
	var _cp = global.players[global.turn]
	TickPassiveForChar(global.turn)
	
	global.justSummoned = false
	// Clear just_unleashed flags
	for (var _d = 0; _d < array_length(_cp.djinn); _d++){
		global.djinnlist[_cp.djinn[_d]].just_unleashed = false
	}
	
	// --- Player ATK decay (outgoing player) ---
	if (_cp.atkmod_fresh) { _cp.atkmod_fresh = false }
	else if (_cp.atkmod > 0) { _cp.atkmod-- }
	else if (_cp.atkmod < 0) { _cp.atkmod++ }

	// --- Psyseal countdown (outgoing player) ---
	if (_cp.psyseal > 0) {
		_cp.psyseal--
		if (_cp.psyseal <= 0) { InjectLog(_cp.name + "'s psynergy is restored!") }
	}

	// --- Poison/venom tick for ALL players and monsters ---
	var _poison_amt = 1
	var _poison_passive = CheckPassive("poison_buff")
	if (_poison_passive != undefined) { _poison_amt = _poison_passive.data.amount }
	for (var i = 0; i < array_length(global.players); i++){
		var _tick_dam = 0
		if global.players[i].poison { global.players[i].hp -= _poison_amt; _tick_dam += _poison_amt }
		if global.players[i].venom { global.players[i].hp -= 3; _tick_dam += 3 }
		if _tick_dam > 0 {
			instance_create_depth(0,0,-200,objDamageNumber,
				{ amount: _tick_dam, world_x: 5 + i * 400 + 100, world_y: 70, col: c_purple, gui_mode: true })
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
	CheckVictory()
	// --- Advance turn ---
	global.playersActed++
	
	for (var _i = 0; _i < 4; _i++) {
			global.turn = (global.turn + 1) mod 4
			if global.players[global.turn].hp > 0 { break }
			TickPassiveForChar(global.turn)
			global.playersActed++
		}
	
	if global.playersActed >= array_length(global.players) {
		// --- End of round: enemy phase, then back to first player ---
		global.playersActed = 0
		global.turnPhase = "enemy"

		DeleteButtons()
		//TickPassives()
		RunEnemyPhase(false, function() {
			// Advance to firstPlayer (first alive from there)
			global.turn = global.firstPlayer
			for (var _i = 0; _i < 4; _i++) {
				if global.players[global.turn].hp > 0 { break }
				global.turn = (global.turn + 1) mod 4
				global.playersActed++
			}

			_NextTurnSetupPlayer()
		})
	} else {
		// --- Mid-round: boss phase, then next player ---
		// Advance to next alive player
		

		global.turnPhase = "boss"
		DeleteButtons()
		RunEnemyPhase(true, function() {
			TickMonsterStatuses()
			_NextTurnSetupPlayer()
		})
	}
}

/// @function _NextTurnSetupPlayer()
/// @desc Set up the new current player's turn (called after enemy phase completes)
function _NextTurnSetupPlayer() {
	
	// Always rebuild dice pool so passive effects (Steam, Kindle, etc.) apply immediately
	CreateDicePool()

	if global.turnPhase == "enemy"{
	// --- Player DEF decay (all living players, at start of new player round) ---
		for (var _pd = 0; _pd < 4; _pd++) {
			var _pp = global.players[_pd]
			if (_pp.hp <= 0) { continue }
			if (_pp.defmod_fresh) { _pp.defmod_fresh = false }
			else if (_pp.defmod > 0) { _pp.defmod-- }
			else if (_pp.defmod < 0) { _pp.defmod++ }
			if _pp.reflect{_pp.reflect = false}
		}
		
		//root and regen ticks
		for (var _r = 0; _r < array_length(global.players); _r++) {
			var _rp = global.players[_r]
			if (_rp.hp > 0 and variable_struct_exists(_rp, "rootTokens") and _rp.rootTokens > 0) {
				_rp.rootTokens--
				_rp.hp = min(_rp.hp + 2, _rp.hpmax)
				_rp.defmod += 1
				_rp.defmod_fresh = true
				InjectLog(_rp.name + " heals 2 HP and gains 1 DEF!")
			}if (_rp.hp > 0 and variable_struct_exists(_rp, "regen") and _rp.regen > 0) {
				_rp.regen--
				_rp.hp+=_rp.regheal
				if _rp.hp > _rp.hpmax{_rp.hp = _rp.hpmax}
				InjectLog(_rp.name + " heals " + string(_rp.regheal) + "!")
			
			}
		}
		
	}

	// Tick reroll expiry for all players at end of round
	if global.turnPhase == "enemy" {
		for (var _ri = 0; _ri < 4; _ri++) {
			var _rr = global.players[_ri].rerolls
			for (var _rj = array_length(_rr) - 1; _rj >= 0; _rj--) {
				if _rr[_rj].expires > 0 {
					_rr[_rj].expires--
					if _rr[_rj].expires <= 0 { array_delete(_rr, _rj, 1) }
				}
			}
		}
	}

	global.turnPhase = "player"

	// --- Downed check (boss may have killed this player) ---
	if global.players[global.turn].hp <= 0 {
		// Skip to next alive player without triggering another boss phase
		for (var _sk = 0; _sk < 4; _sk++) {
			TickPassiveForChar(global.turn)
			global.turn = (global.turn + 1) mod 4
			global.playersActed++
			if global.players[global.turn].hp > 0 { break }
		}
		// Party wipe check
		CheckVictory()
	}

	var _cur = global.players[global.turn]

	// --- Sleep check ---
	if _cur.sleep {
		if irandom(1) == 0 {
			InjectLog(_cur.name + " is asleep!")
			_AdvanceTurn()
			return
		} else {
			InjectLog(_cur.name + " woke up!")
			_cur.sleep = false
		}
	}

	// --- Stun check ---
	if _cur.stun > 0 {
		if irandom(1) == 0 {
			InjectLog(_cur.name + " is stunned!")
			_cur.stun--
			_AdvanceTurn()
			return
		} else {
			_cur.stun--
		}
	}

// --- Curse check (cursed armor: d6, 1-2 = skip turn) ---
	if _cur.cursed {
		// Cleric's Ring negates curse turn-skip
		var _hasClerics = false
		for (var _ci = 0; _ci < array_length(_cur.armor); _ci++) {
			if (global.itemcardlist[_cur.armor[_ci]].name == "Cleric's Ring") {
				_hasClerics = true
				break
			}
		}
		if (!_hasClerics) {
			var _curseRoll = irandom(5) + 1
			if (_curseRoll <= 2) {
				PushMenu(objMenuDialog, {
					text:    _cur.name + " is under a curse!",
					subtext: "Their turn is skipped.",
					buttons: [{
						label: "Continue", sprite: yes,
						on_click: function() {
							PopMenu()
							_AdvanceTurn()
						}
					}]
				})
				return
			}
		}
	}

	// PP regen
	if global.inCombat {
		_cur.pp += _cur.ppinc
		if _cur.pp > _cur.ppmax {
			_cur.pp = _cur.ppmax
		}
	}

	_cur.dicepool = RollDice(_cur)

	// Lucky Cap: grant 1 single-die reroll per turn
	for (var _ai = 0; _ai < array_length(_cur.armor); _ai++) {
		if global.itemcardlist[_cur.armor[_ai]].name == "Lucky Cap" {
			array_push(_cur.rerolls, {mode: "single", uses: 1, source: "Lucky Cap", expires: -1})
			break
		}
	}

	// Mint: grant 1 single-die reroll per turn (permanent boss reward)
	if (variable_struct_exists(_cur, "mint") && _cur.mint) {
		array_push(_cur.rerolls, {mode: "single", uses: 1, source: "Mint", expires: -1})
	}

	// Recreate action buttons for the new player's turn
	if global.inCombat and !instance_exists(objAttack) {
		CreateOptions()
	}

	// Planet Diver stage 2 detonation — fires automatically on the next turn after charging
	if global.inCombat and variable_struct_exists(_cur, "planetary") and _cur.planetary.active {
		_cur.planetary.active = false
		_cur.halfheal = false
		var _pkt = variable_clone(global.AggressionSchema)
		_pkt.source  = "psynergy"
		_pkt.dam     = _cur.planetary.damage
		_pkt.dmgtype = _cur.planetary.element
		_pkt.target  = "enemy"
		_pkt.num     = 1
		DeleteButtons()
		InjectLog(_cur.name + " unleashes the planetary strike!")
		SelectTargets(_pkt)
	}
}
