/// @function _SetFloorRequired()
/// @desc Sets global.floorRequired based on challenge count. Puzzles cap the max.
/// @note Kept for reference — no longer called at runtime (pre-computed in _PreGenerateFloors)
function _SetFloorRequired() {
	var _total = array_length(global.floorChallenges)
	var _has_puzzle = false
	for (var _i = 0; _i < _total; _i++) {
		if (global.floorChallenges[_i].type == "puzzle") { _has_puzzle = true; break }
	}
	var _max_req = _has_puzzle ? max(1, _total - 1) : _total
	global.floorRequired = irandom_range(1, _max_req)
}

/// @function LoadFloor()
/// @desc Loads current floor data from pre-generated global.dungeonFloors[]
function LoadFloor() {
	var _floor_data = global.dungeonFloors[global.dungeonFloor - 1]

	global.floorChallenges = _floor_data.challenges
	global.floorRequired = _floor_data.required
	global.floorEffects = _floor_data.effects
	global.floorName = variable_struct_exists(_floor_data, "floor_name") ? _floor_data.floor_name : ""
	global.noHealOnCombatEnd = false
	global.cloakActive = false
	global.onFloor = false

	// Update overworld background — boss floor uses boss_background
	var _bg_layer = layer_background_get_id(layer_get_id("Background"))
	var _dun = global.dungeonlist[global.dungeon]
	var _is_boss_floor = (global.dungeonFloor == array_length(global.dungeonFloors))
	layer_background_sprite(_bg_layer, _is_boss_floor ? _dun.boss_background : _dun.background)
}

/// @function GenerateFloor()
/// @desc Legacy wrapper — calls LoadFloor() for backwards compatibility
function GenerateFloor() {
	LoadFloor()
}
