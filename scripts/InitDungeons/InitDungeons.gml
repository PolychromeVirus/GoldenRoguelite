function InitDungeons() {
	global.dungeonlist = []

	// Load dungeon definitions
	var _grid = load_csv("DungeonImport.csv")

	for (var i = 1; i < ds_grid_height(_grid); i++) {
		// Parse reward_schedule "3:levelup;5:djinn;7:levelup" into struct
		var _reward_str = _grid[# 6, i]
		var _rewards = {}
		if (_reward_str != "") {
			var _pairs = string_split(_reward_str, ";")
			for (var p = 0; p < array_length(_pairs); p++) {
				var _kv = string_split(_pairs[p], ":")
				if (array_length(_kv) == 2) {
					_rewards[$ _kv[0]] = _kv[1]
				}
			}
		}

		// Parse towns
		var _town_str = _grid[# 7, i]
		var _towns = (_town_str != "") ? string_split(_town_str, ";") : []

		var _dun = {
			name: _grid[# 0, i],
			floors: real(_grid[# 1, i]),
			background: asset_get_index(_grid[# 2, i]),
			boss: _grid[# 4, i],
			curse_chance: real(_grid[# 5, i]),
			rewards: _rewards,
			towns: _towns,
			min_challenges: real(_grid[# 8, i]),
			max_challenges: real(_grid[# 9, i]),
			overrides: []
		}
		var _boss_bg_str = _grid[# 10, i]
		_dun.boss_background = (_boss_bg_str != "") ? asset_get_index(_boss_bg_str) : _dun.background

		array_push(global.dungeonlist, _dun)
	}

	ds_grid_destroy(_grid)

	// Load floor overrides
	var _ogrid = load_csv("DungeonOverrides.csv")

	for (var i = 1; i < ds_grid_height(_ogrid); i++) {
		var _dungeon_name = _ogrid[# 0, i]
		var _override = {
			dungeon: _dungeon_name,
			floor_num: real(_ogrid[# 1, i]),
			type: _ogrid[# 2, i],
			troops_a: (_ogrid[# 3, i] != "") ? string_split(_ogrid[# 3, i], ";") : [],
			troops_b: (_ogrid[# 4, i] != "") ? string_split(_ogrid[# 4, i], ";") : [],
			solo: (_ogrid[# 5, i] == "TRUE"),
			unique: (_ogrid[# 6, i] == "TRUE"),
			name: (_ogrid[# 7, i] != "") ? _ogrid[# 7, i] : ""
		}

		// Attach to matching dungeon
		for (var d = 0; d < array_length(global.dungeonlist); d++) {
			if (global.dungeonlist[d].name == _dungeon_name) {
				array_push(global.dungeonlist[d].overrides, _override)
				break
			}
		}
	}

	ds_grid_destroy(_ogrid)
}
