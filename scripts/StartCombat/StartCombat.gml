function StartCombat(_troop_override) {
	global.goldAtCombatStart = global.gold
	global.noHealOnCombatEnd = false
	global.cloakActive = false

	// Switch background for combat — use dungeon background
	global.darken = true
	var _bg_layer = layer_background_get_id(layer_get_id("Background"))
	var _dun = global.dungeonlist[global.dungeon]
	var _is_boss_floor = (global.dungeonFloor == array_length(global.dungeonFloors))
	var _bg = _is_boss_floor ? _dun.boss_background : _dun.background
	layer_background_sprite(_bg_layer, _bg)

	var drawy = 104
	var drawpad = 10

	// Use provided troop or pick random from dungeon pool
	var troop
	if (_troop_override != undefined && array_length(_troop_override) > 0) {
		troop = _troop_override
	} else {
		troop = global.dungeonTroops[irandom(array_length(global.dungeonTroops)-1)]
	}
	var divis = array_length(troop)+1

	var left = drawpad
	var right = room_width-drawpad
	var split = (right-left)/divis

	var drawx = drawpad + split

	// Reset extra turns
	for (var _et = 0; _et < 4; _et++) { global.players[_et].extraTurns = 0 }

	global.players[0].dicepool = RollDice(global.players[0])
	global.players[1].dicepool = RollDice(global.players[1])
	global.players[2].dicepool = RollDice(global.players[2])
	global.players[3].dicepool = RollDice(global.players[3])

	for(var i=0;i<divis-1;i++){

		var temp = variable_clone(global.monsterlist[0])

		for(var j=0;j<array_length(global.monsterlist);j++){
			if global.monsterlist[j].name == troop[i]{
				temp = variable_clone(global.monsterlist[j])
			}
		}

		temp.slotID = i
		if temp.boss{ temp.maxhp += global.hpcurse * 10 }else{ temp.maxhp += global.hpcurse * 3}
		if temp.boss{ temp.monsterHealth += global.hpcurse * 10 }else{ temp.monsterHealth += global.hpcurse * 3}
		temp.res += global.rescurse
		temp.atk += global.atkcurse
		instance_create_depth(drawx,drawy,5,objMonster,temp)
		drawx += split
	}

	// Set Ground to Set state at combat start (condition: starts combat face down)
	for (var _gp = 0; _gp < array_length(global.players); _gp++) {
		var _gdj = global.players[_gp].djinn
		for (var _gd = 0; _gd < array_length(_gdj); _gd++) {
			var _gdjinn = global.djinnlist[_gdj[_gd]]
			if (_gdjinn.name == "Ground" && _gdjinn.ready) {
				_gdjinn.ready = false
				_gdjinn.spent = true
			}
		}
	}

	// Clear passives at combat start
	global.passiveEffects = []

	// Apply active floor effects (traps, puzzle rewards)
	ApplyFloorEffects()

	// Initialize turn phase state
	global.playersActed = 0
	global.turnPhase = "boss"

	// Set turn to firstPlayer (find first alive from there)
	global.turn = global.firstPlayer
	for (var _i = 0; _i < 4; _i++) {
		if global.players[global.turn].hp > 0 { break }
		global.turn = (global.turn + 1) mod 4
	}

	// Check for Speedy Enemies floor effect — enemies act first
	var _speedy = false
	for (var _se = 0; _se < array_length(global.floorEffects); _se++) {
		if (global.floorEffects[_se].name == "Speedy Enemies") { _speedy = true; break }
	}
	if (_speedy) {
		RunEnemyPhase(false)
	}

	// Run boss phase before first player's turn (Halt can skip this)
	var _has_boss = false
	for (var _bi = 0; _bi < instance_number(objMonster); _bi++) {
		if (instance_find(objMonster, _bi).boss == 1) { _has_boss = true; break }
	}

	var _halt_caster = _has_boss ? FindSpellCaster("Halt") : -1
	
	BattleMusic(_has_boss)
	
	if (_halt_caster >= 0) {
		SpellPrompt("Halt", _halt_caster,
			function() {
				// Skip boss pre-turn phase; boss acts after player 1 via NextTurn
				global.turnPhase = "player"
				global.players[global.turn].dicepool = RollDice(global.players[global.turn])
				global.players[global.turn].pp += global.players[global.turn].ppinc
				if global.players[global.turn].pp > global.players[global.turn].ppmax { global.players[global.turn].pp = global.players[global.turn].ppmax }
				
			},
			function() {
				RunEnemyPhase(true)
				global.turnPhase = "player"
				global.players[global.turn].dicepool = RollDice(global.players[global.turn])
				global.players[global.turn].pp += global.players[global.turn].ppinc
				if global.players[global.turn].pp > global.players[global.turn].ppmax { global.players[global.turn].pp = global.players[global.turn].ppmax }
			}
		)
	} else {
		RunEnemyPhase(true)

		// Set up first player's dice
		global.turnPhase = "player"
		global.players[global.turn].dicepool = RollDice(global.players[global.turn])
		global.players[global.turn].pp += global.players[global.turn].ppinc
		if global.players[global.turn].pp > global.players[global.turn].ppmax{global.players[global.turn].pp = global.players[global.turn].ppmax}
	}
}
