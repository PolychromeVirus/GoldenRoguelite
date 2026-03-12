function LoadTroopCSV(_filename) {
	var _troops = []
	var _grid = load_csv(_filename)

	for (var i = 1; i < ds_grid_height(_grid); i++) {
		var _troop = []
		for (var j = 0; j < real(_grid[# 0, i]); j++) {
			array_push(_troop, _grid[# j+1, i])
		}
		array_push(_troops, _troop)
	}

	ds_grid_destroy(_grid)
	return _troops
}
