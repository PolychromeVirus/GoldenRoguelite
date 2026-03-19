function NextFloor() {
	var _dun = global.dungeonlist[global.dungeon]

	// Curse check — random chance per floor
	if (irandom(99) < _dun.curse_chance) {
		DifficultyUp()
	}

	// Guaranteed health curse after completing floor 4
	if (global.dungeonFloor == 4) {
		DifficultyUp(0)
	}

	// Fixed reward for this floor number
	var _has_reward = false
	var _floor_key = string(global.dungeonFloor)
	if (variable_struct_exists(_dun.rewards, _floor_key)) {
		var _reward = _dun.rewards[$ _floor_key]
		if (_reward == "levelup") {
			_has_reward = true
			InjectLog("Floor Reward! Level Up!")
			LevelUp()
		}
		if (_reward == "djinn") {
			_has_reward = true
			InjectLog("Floor Reward! Djinni!")
			DjinnDraft()
		}
		if (_reward == "summon") {
			_has_reward = true
			InjectLog("Floor Reward! Summon Tablet!")
			SummonDraft()
		}
	}

	// Clear floor effects from previous floor
	global.floorEffects = []
	global.noHealOnCombatEnd = false
	global.cloakActive = false

	global.dungeonFloor++
	global.floor++

	// Check if all pre-generated floors are exhausted
	if (global.dungeonFloor > array_length(global.dungeonFloors)) {
		CompleteDungeon()
		return  // Boss rewards handle their own UI flow
	} else {
		LoadFloor()
	}

	// If no reward UI was spawned, refresh buttons now
	if (!_has_reward) {
		CreateOptions()
		Autosave()
	}
	
}
