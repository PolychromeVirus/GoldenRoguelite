/// @function ApplyFloorEffects()
/// @desc Called at the start of StartCombat to apply active trap effects
function ApplyFloorEffects() {
	for (var _i = 0; _i < array_length(global.floorEffects); _i++) {
		var _eff = global.floorEffects[_i]
		var _name = _eff.name

		if (_name == "Stolen Supplies") {
			global.noHealOnCombatEnd = true
		}
		else if (_name == "Sentry Statues") {
			// Jupiter enemies get +3 atkmod — applied after monsters spawn
			for (var _m = 0; _m < instance_number(objMonster); _m++) {
				var _mon = instance_find(objMonster, _m)
				if (_mon.element == "jupiter") _mon.atkmod += 3
			}
		}
		else if (_name == "Evil Desert Wind") {
			// Venus enemies get +3 atkmod
			for (var _m = 0; _m < instance_number(objMonster); _m++) {
				var _mon = instance_find(objMonster, _m)
				if (_mon.element == "venus") _mon.atkmod += 3
			}
		}
		else if (_name == "Speedy Enemies") {
			_eff.applied = true // Flag checked in StartCombat to run enemy phase first
		}
		else if (_name == "Statue Trap") {
			// Spawn 2 additional random enemies from dungeon pool
			var _pool = global.dungeonTroops
			for (var _s = 0; _s < 2; _s++) {
				var _troop = _pool[irandom(array_length(_pool) - 1)]
				var _mon_name = _troop[irandom(array_length(_troop) - 1)]
				var _template = global.monsterlist[0]
				for (var _j = 0; _j < array_length(global.monsterlist); _j++) {
					if (global.monsterlist[_j].name == _mon_name) {
						_template = global.monsterlist[_j]
						break
					}
				}
				_template.extra = true
				_template.slotID = instance_number(objMonster)
				instance_create_depth(irandom_range(40, room_width - 40), 100, 5, objMonster, _template)
			}
		}
		else if (_name == "Falling Rocks") {
			for (var _p = 0; _p < 4; _p++) {
				global.players[_p].hp = max(1, global.players[_p].hp - 2)
			}
			InjectLog("Rocks fall! All adepts lose 2 HP!")
		}
		else if (_name == "Poison Spike") {
			var _alive = []
			for (var _p = 0; _p < 4; _p++) {
				if (global.players[_p].hp > 0) array_push(_alive, _p)
			}
			if (array_length(_alive) > 0) {
				var _target = _alive[irandom(array_length(_alive) - 1)]
				global.players[_target].poison = true
				InjectLog(global.players[_target].name + " is poisoned by a spike!")
			}
		}
		else if (string_pos("Overload", _name) > 0) {
			// Deal elemental affinity damage to all adepts
			var _elem = ""
			if (string_pos("Venus", _name) > 0) _elem = "venus"
			else if (string_pos("Mars", _name) > 0) _elem = "mars"
			else if (string_pos("Jupiter", _name) > 0) _elem = "jupiter"
			else if (string_pos("Mercury", _name) > 0) _elem = "mercury"
			var _affinity = 0
			for (var _p = 0; _p < 4; _p++) {
				_affinity += QueryDice(global.players[_p], _elem, "affinity")
			}
			for (var _p = 0; _p < 4; _p++) {	
				if (global.players[_p].hp <= 0) continue
				global.players[_p].hp = max(1, global.players[_p].hp - _affinity)
			}
			
			InjectLog(_elem + " overload deals affinity damage!")
		}
		else if (_name == "Magic Powder") {
			for (var _p = 0; _p < 4; _p++) {
				if (global.players[_p].hp > 0) global.players[_p].stun = true
			}
			InjectLog("Magic powder stuns all adepts!")
		}
		else if (_name == "Sleeping Gas") {
			for (var _p = 0; _p < 4; _p++) {
				if (global.players[_p].hp > 0) global.players[_p].sleep = true
			}
			InjectLog("Sleeping gas puts all adepts to sleep!")
		}
		else if (_name == "Psy Seal") {
			for (var _p = 0; _p < 4; _p++) {
				if (global.players[_p].hp > 0) global.players[_p].psyseal = 1
			}
			InjectLog("Psynergy sealed for the first turn!")
		}
		else if (_name == "Armory") {
			for (var _m = 0; _m < instance_number(objMonster); _m++) {
				var _mon = instance_find(objMonster, _m)
				_mon.atkmod += 2
				_mon.defmod += 2
			}
			InjectLog("Enemies found an armory! +2 atk/def!")
		}
		// Non-trap floor effects (from rewards)
		else if (_name == "cloak_round1") {
			// Handled in damage calculation — flag checked there
			global.cloakActive = true
		}
		else if (_name == "enemy_def_down") {
			for (var _m = 0; _m < instance_number(objMonster); _m++) {
				var _mon = instance_find(objMonster, _m)
				_mon.defmod -= 1
			}
		}
	}
}

/// @function ApplyPuzzleReward(puzzle)
/// @desc Applies non-trap puzzle rewards immediately on disarm
function ApplyPuzzleReward(_puzzle) {
	var _name = _puzzle.name

	if (_name == "Catch") {
		instance_create_depth(0,0,0,objInsightDisplay)
		InjectLog("You glimpse the challenges ahead!")
	}
	else if (_name == "Cloak") {
		array_push(global.floorEffects, { name: "cloak_round1", puzzle_index: -1 })
		InjectLog("Cloak grants protection for round 1 of next combat!")
	}
	else if (_name == "Douse") {
		array_push(global.floorEffects, { name: "enemy_def_down", puzzle_index: -1 })
		InjectLog("Douse weakens enemy defenses! (-1 DEF)")
	}
	else if (_name == "Force") {
		for (var _p = 0; _p < 4; _p++) {
			var _pl = global.players[_p]
			_pl.poison = false
			_pl.stun = false
			_pl.sleep = false
			_pl.psySeal = 0
			_pl.delude = false
		}
		InjectLog("Party snapped out of their conditions!")
	}
	else if (_name == "Halt") {
		// Roll d4, on 1 trigger djinni trade
		if (irandom(3) == 0) {
			InjectLog("You halted a djinni before it could run away!")
			DjinnDraft()
		} else {
			InjectLog("A djinni got away...")
		}
	}
	else if (_name == "Move") {
		for (var _p = 0; _p < 4; _p++) {
			DrawCard(global.players[_p])
			DrawCard(global.players[_p])
		}
		InjectLog("Path cleared! All players draw 2 cards!")
	}
	else if (_name == "Reveal") {
		for (var _p = 0; _p < 4; _p++) {
			array_push(global.choiceDrawQueue, _p)
		}
		ProcessChoiceDrawQueue()
		InjectLog("Found some hidden items! Choice draw for all!")
	}
	else if (_name == "Whirlwind") {
		global.gold += 10
		InjectLog("You pick up some coins in the wind!")
	}
	else if (_name == "Frost") {
		// Roll d4, on 1 a djinni joins
		if (irandom(3) == 0) {
			InjectLog("There was a djinni on the other side!")
			DjinnDraft()
		} else {
		}
	}
}