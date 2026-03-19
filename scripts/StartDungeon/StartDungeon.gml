function StartDungeon(_dungeon_index) {
	global.dungeon = _dungeon_index
	global.dungeonFloor = 1
	global.defeatedMiniBosses = []
	global.onFloor = false

	var _dun = global.dungeonlist[global.dungeon]
	var _troop_file = string_replace_all(_dun.name, " ", "_") + "_Troops.csv"
	global.dungeonTroops = LoadTroopCSV(_troop_file)
	global.genbackground = _dun.background
	global.genBGM = asset_get_index("BGM_" + string_replace_all(_dun.name, " ", "_"))
	// Build artifact pool from previous chapter (skip ch0)
	_BuildArtifactList()

	// Pre-generate all floors
	_PreGenerateFloors(_dun)
	//create this chapter's deck
	_GenerateDeck(_dun)
	
	randomise()
	global.deck = array_shuffle(global.deck)
	
	for (var i = 0; i < array_length(global.players); ++i) {
	    var _curr = global.players[i]

		_curr.hp = variable_clone(_curr.hpmax)
		_curr.pp = 3 * (_dungeon_index + 1)
		CreateDicePool()
		_curr.dicepool = RollDice(_curr)
		ClearAllTokens(_curr,true)
	}
	
	
	// Load the first floor
	LoadFloor()
	audio_stop_all()
	audio_play_sound(global.genBGM,1,1)
	
}

/// @function _GenerateDeck(dun)
/// @desc Takes in dungeon struct and builds the chapter deck based on DungeonName_Recipe.csv
function _GenerateDeck(_dun){
	//initialize deck and discard
	global.deck = []
	global.discard = []
	var _deck_file = string_replace_all(_dun.name, " ", "_") + "_Recipe.csv"
	var f = load_csv(_deck_file)
	
	for (var i = 0; i < ds_grid_height(f); ++i) {
		var amt = real( f[# 1, i] )
	    for (var j = 0; j < amt; ++j) {
		    array_push(global.deck,FindItemID(f[# 0,i]))
		}
	}
	
	
}

/// @function _PreGenerateFloors(dun)
/// @desc Builds global.dungeonFloors[] — one struct per floor including boss
function _PreGenerateFloors(_dun) {
	global.dungeonFloors = []

	// Split pool into regular and mini-boss (single-enemy) troops
	var _regular = []
	var _all_minibosses = []
	for (var i = 0; i < array_length(global.dungeonTroops); i++) {
		if (array_length(global.dungeonTroops[i]) == 1) {
			array_push(_all_minibosses, global.dungeonTroops[i])
		} else {
			array_push(_regular, global.dungeonTroops[i])
		}
	}

	// Determine which floors are solo-override (can't place mini-bosses there)
	var _solo_floors = []  // 1-based floor numbers that have solo overrides
	for (var f = 1; f <= _dun.floors; f++) {
		for (var oi = 0; oi < array_length(_dun.overrides); oi++) {
			var _ov = _dun.overrides[oi]
			if (_ov.floor_num == f && _ov.solo) {
				array_push(_solo_floors, f)
				break
			}
		}
	}

	// Mini-boss placement: assign each mini-boss to a unique non-solo floor
	var _available_floors = []
	for (var f = 1; f <= _dun.floors; f++) {
		if (!array_contains(_solo_floors, f)) {
			array_push(_available_floors, f)
		}
	}
	array_shuffle(_available_floors)

	// Map: floor_num -> mini-boss troop
	var _miniboss_assignments = {}  // floor_num (string key) -> troop array
	var _mb_count = min(array_length(_all_minibosses), array_length(_available_floors))
	var _mb_copy = array_create(array_length(_all_minibosses))
	array_copy(_mb_copy, 0, _all_minibosses, 0, array_length(_all_minibosses))
	array_shuffle(_mb_copy)
	for (var i = 0; i < _mb_count; i++) {
		_miniboss_assignments[$ string(_available_floors[i])] = _mb_copy[i]
	}

	// Generate each floor 1..floors
	for (var f = 1; f <= _dun.floors; f++) {
		var _challenges = []
		var _effects = []
		var _solo_override = false
		var _floor_name = ""

		// Check overrides for this floor
		for (var oi = 0; oi < array_length(_dun.overrides); oi++) {
			var _ov = _dun.overrides[oi]
			if (_ov.floor_num != f) continue
			if (_ov.name != "") { _floor_name = _ov.name }

			// Pick troops_a or troops_b
			var _troop = _ov.troops_a
			if (array_length(_ov.troops_b) > 0 && irandom(1) == 0) {
				_troop = _ov.troops_b
			}

			var _challenge = {
				type: _ov.type,
				troop: _troop,
				completed: false,
				unique: _ov.unique,
				override_name: ""
			}
			if (_ov.unique) {
				var _name = ""
				for (var t = 0; t < array_length(_ov.troops_a); t++) {
					_name += _ov.troops_a[t]
					if (t < array_length(_ov.troops_a) - 1) _name += ";"
				}
				_challenge.override_name = _name
			}

			array_push(_challenges, _challenge)

			if (_ov.solo) { _solo_override = true; break }
		}

		// If not solo, fill challenge slots
		if (!_solo_override) {
			var _num = irandom_range(_dun.min_challenges, _dun.max_challenges)
			var _existing = array_length(_challenges)

			// Check if this floor has a mini-boss assigned
			var _floor_key = string(f)
			var _has_mb = variable_struct_exists(_miniboss_assignments, _floor_key)
			var _mb_placed = false

			for (var i = _existing; i < _num; i++) {
				// Place mini-boss in one slot
				if (_has_mb && !_mb_placed) {
					var _mb_troop = _miniboss_assignments[$ _floor_key]
					array_push(_challenges, {
						type: "combat",
						troop: _mb_troop,
						completed: false,
						unique: true,
						override_name: _mb_troop[0]
					})
					_mb_placed = true
				} else if (array_length(_regular) > 0) {
					var _troop = _regular[irandom(array_length(_regular) - 1)]
					array_push(_challenges, {
						type: "combat",
						troop: _troop,
						completed: false,
						unique: false,
						override_name: ""
					})
				}
			}
		}

		// 33% chance to add a puzzle challenge
		if (array_length(global.puzzlelist) > 0 && irandom(2) == 0) {
			var _pi = _BuildRandomPuzzleChallenge()
			if _pi.success{
				array_push(_challenges, _pi.challenge)
				_effects = array_concat(_effects, _pi.effects)
			}else{
				InjectLog("Puzzle CSV not found!")
			}
		}

		// Compute floorRequired
		var _total = array_length(_challenges)
		var _has_puzzle = false
		for (var i = 0; i < _total; i++) {
			if (_challenges[i].type == "puzzle") { _has_puzzle = true; break }
		}
		var _max_req = _has_puzzle ? max(1, _total - 1) : _total
		var _required = irandom_range(1, _max_req)

		array_push(global.dungeonFloors, {
			challenges: _challenges,
			required: _required,
			effects: _effects,
			floor_name: _floor_name
		})
	}

	// Append boss floor as final entry — check for override name
	var _boss_floor_name = ""
	for (var oi = 0; oi < array_length(_dun.overrides); oi++) {
		if (_dun.overrides[oi].floor_num == _dun.floors + 1 && _dun.overrides[oi].name != "") {
			_boss_floor_name = _dun.overrides[oi].name
			break
		}
	}
	array_push(global.dungeonFloors, {
		challenges: [{
			type: "boss",
			troop: string_split(_dun.boss, ";"),
			completed: false,
			unique: false,
			override_name: ""
		}],
		required: 1,
		effects: [],
		floor_name: _boss_floor_name
	})
}
